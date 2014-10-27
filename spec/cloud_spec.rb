require 'singleton'
require 'json'

class CloudStatus 

  include Singleton

  attr_reader :cloud_domain, :influxdb_url

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

  def influxdb_url 
    "influxdb.#{environment_name}.#{cloud_domain}"
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
                    zookeeper@1.service
                    zookeeper@2.service
                    zookeeper@3.service
                    zookeeper.data@1.service
                    zookeeper.data@2.service
                    zookeeper.data@3.service
                    zookeeper.presence@1.service
                    zookeeper.presence@2.service
                    zookeeper.presence@3.service
                    )
    unit_names.each do |unit_name|
      expect(@status).to have_unit(unit_name), "The #{unit_name} unit was not found."
    end
  end

  it "should be able to access the public influx endpoint" do
    out = %x(dig +short #{@status.influxdb_url})
    expect(out).to match(/[0-9]./), "The influxdb url (#{@status.influxdb_url}) is not found (no Route53?)."
  end

  it "should be able to access influxdb public port and get time-series data" do
    
    query = "q=select * from /.*/ limit 1" #list-series

    dbs = %W(sysinfo cadvisor grafana)
    dbs.each do |db|
      cmd = "curl -GfsS 'http://#{@status.influxdb_url}:8086/db/sysinfo/series?u=root&p=root' --data-urlencode '#{query}' 2>&1"
      out = %x(#{cmd})
      expect(out).to_not include("Could not resolve host")
      # expect(out).to start_with("[{"), "The response from the influxdb server is not JSON (#{out})"
      response = nil
      expect{ response = JSON.parse(out) }.to_not raise_error
      expect(response.size).to be > 0, "The influxdb #{db} database contains no series."
    end
  end

end
