require 'singleton'
require 'json'

class CloudStatus 

  include Singleton

  attr_reader :cloud_domain

  public

  def initialize
    @cluster_values_filepath = 'terraform/cluster_values.tfvars'
    @cloud_domain = 'cloud.nlab.io'
  end

  def ip
    ENV['FLEETCTL_TUNNEL']
  end

  def has_cluster_values_file?
    return File.exist?(@cluster_values_filepath)
  end

  def environment_name
    return nil unless has_cluster_values_file?
    return @environment_name unless @environment_name.nil?
    @environment_name = File.open(@cluster_values_filepath, &:readline).match(/"(.*)"/)[1]
  end

  def machines
    return @machines unless @machines.nil?
    out = %x(fleetctl list-machines)
    @machines = out.scan(/\t(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\t/).flatten
  end

  def units
    return @units unless @units.nil?
    out = %x(fleetctl list-units)
    @units = []
    out.scan(/\b(\S+)\b/).each_slice(4) do |unit|
      @units << Unit.new(unit.flatten)
    end
    @units
  end

  def unit_names
    units.map{ |unit| unit.unit }
  end

  def has_unit?(unit)
    unit_names.include?(unit)
  end

end

class Unit
  attr_accessor :unit, :machine, :active, :sub
  def initialize(unit_array)
    @unit, @machine, @active, @sub = unit_array
  end
end

RSpec.describe CloudStatus do
  
  before :all do
    @status = CloudStatus.instance
  end

  it "should have an environment name set in terraform/cluster_values.tfvars" do
    expect(@status.has_cluster_values_file?).to be_truthy, "terraform/cluster_values.tfvars file does not exist. Please run new_cluster_values from the terraform directory."
    expect(@status.environment_name).to_not be_nil
  end

  it "should have FLEETCTL_TUNNEL environment variable set for local tests" do
    expect(ENV['FLEETCTL_TUNNEL']).to_not be_nil, "For fleet tests, you need to have your FLEETCTL_TUNNEL environment variable exported as the public ip address of a machine in your cluster."
  end

  it "should contain 3 machines" do
    expect(@status.machines.size).to eq(3)
  end

  it "should have the necessary units" do
    unit_names = %W(influxdb@1.service 
                    influxdb.presence@1.service
                    influxdb.elb@1.service
                    cadvisor.service
                    skydns.service
                    sysinfo_influxdb.service
                    )
    unit_names.each do |unit_name|
      expect(@status.has_unit?(unit_name)).to be_truthy, "The #{unit_name} unit was not found."
    end
  end

  it "should be able to access influxdb public port and get time-series data" do
    influxdb_url = "influxdb.#{@status.environment_name}.#{@status.cloud_domain}"
    query = "q=select * from /.*/ limit 1" #list-series

    dbs = %W(sysinfo cadvisor grafana)
    dbs.each do |db|
      out = %x(curl -G -f -s 'http://#{influxdb_url}:8086/db/sysinfo/series?u=root&p=root' --data-urlencode '#{query}')

      expect(out).to_not include("Could not resolve host")
      expect(out).to start_with("[{"), "The response from the influxdb server is not JSON."
      response = JSON.parse(out)
      expect(response.size).to be > 0, "The influxdb #{db} database contains no series."
    end
  end

end
