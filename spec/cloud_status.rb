class CloudStatus 

  attr_reader :cluster_values_filepath, :cloud_domain

  def initialize(cluster_values_filepath, cloud_domain)
    @cluster_values_filepath = Pathname.new(cluster_values_filepath)
    @cloud_domain = cloud_domain
  end

  def has_cluster_values_file?
    @cluster_values_filepath.exist?
  end

  def cluster_values
    @cluster_values ||=
      Hash[*@cluster_values_filepath.readlines.map { |l| l.chomp.gsub('"', '').split(" = ") }.flatten]
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

  def influxdb_hostname 
    "influxdb.#{environment_name}.#{cloud_domain}"
  end
end

FleetMachine = Struct.new(:machine_id, :ip, :metadata) do
  def initialize(machine_id, ip, metadata)
    super(machine_id, ip, Hash[*metadata.split(/[,=]/)])
  end
end

FleetUnit = Struct.new(:unit_name, :machine_id, :active_state, :sub_state)
