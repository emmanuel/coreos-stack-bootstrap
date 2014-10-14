class CloudStatus 

  public

  def ip
    ENV['FLEETCTL_TUNNEL']
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
    @status = CloudStatus.new
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

end
