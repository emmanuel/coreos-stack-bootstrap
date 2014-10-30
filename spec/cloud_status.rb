require 'pathname'
require 'uri'
require 'ipaddr'

class CloudStatus 

  attr_reader :fleetctl_tunnel_ip, :cluster_values_pathname, :cloud_domain

  def initialize(fleetctl_tunnel_ip, cluster_values_filepath, cloud_domain)
    @fleetctl_tunnel_ip = (fleetctl_tunnel_ip || nil) && IPAddr.new(fleetctl_tunnel_ip)
    @cluster_values_pathname = Pathname.new(cluster_values_filepath)
    @cloud_domain = cloud_domain
  end

  def influxdb
    @influxdb ||= InfluxDB.new(environment_name, cloud_domain, 8086, "root", "root")
  end

  def has_cluster_values_file?
    @cluster_values_pathname.exist?
  end

  def cluster_values
    @cluster_values ||=
      Hash[*@cluster_values_pathname.readlines.map { |l| l.chomp.gsub('"', '').split(" = ") }.flatten]
  end

  def environment_name
    cluster_values["environment"]
  end

  def machines
    @machines ||= begin
      machine_list = %x(fleetctl list-machines --full --no-legend --fields machine,ip,metadata)
      machine_list.each_line.map do |line|
        FleetMachine.new(*line.split(/\s+/))
      end
    end
  end

  def units
    @units ||= begin
      unit_list = %x(fleetctl list-units --full --no-legend --fields unit,machine,active,sub)
      unit_list.each_line.map do |line|
        FleetUnit.new(*line.split(/\s+/))
      end
    end
  end

  def unit_names
    units.map(&:unit_name)
  end

  def has_unit?(unit)
    unit_names.include?(unit)
  end


  FleetMachine = Struct.new(:machine_id, :ip, :metadata) do
    def initialize(machine_id, ip, metadata)
      super(machine_id, ip, Hash[*metadata.split(/[,=]/)])
    end
  end

  FleetUnit = Struct.new(:unit_name, :machine_id, :active_state, :sub_state)

  InfluxDB = Struct.new(:environment_name, :cloud_domain, :port, :username, :password) do
    def hostname 
      "influxdb.#{environment_name}.#{cloud_domain}"
    end

    def healthcheck_url
      URI::HTTP.build([userinfo=nil, hostname, port, "/ping", query=nil, fragment=nil])
    end

    def database_query_url(db, query)
      url_query = URI.encode_www_form("u" => username, "p" => password, "q" => query)
      URI::HTTP.build([userinfo=nil, hostname, port, "/db/#{db}/series", url_query, fragment=nil])
    end
  end
end
