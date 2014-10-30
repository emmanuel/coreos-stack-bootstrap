require 'pathname'
require 'uri'
require 'ipaddr'
require 'json'
require_relative 'cloud_status'

status = CloudStatus.new(ENV['FLEETCTL_TUNNEL'], 'terraform/cluster_values.tfvars', 'cloud.nlab.io')

RSpec.describe CloudStatus do
  it "has an environment name set in terraform/cluster_values.tfvars" do
    expect(status.cluster_values_pathname).to exist,
      "#{status.cluster_values_pathname} does not exist. Please run new_cluster_values from the terraform directory."
    expect(status.environment_name).to_not be_nil
    expect(status.environment_name).to match(/[a-z]{5}/)
  end

  it "has a FLEETCTL_TUNNEL environment variable set for local tests" do
    expect(status.fleetctl_tunnel_ip).to be_kind_of(IPAddr),
      "For fleet tests, you need to have your FLEETCTL_TUNNEL environment variable exported as the public ip address of a machine in your cluster."
  end

  it "should contain 3 machines" do
    expect(status.machines.size).to eq(3)
  end

  describe "launched units" do
    %W(influxdb@1.service 
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
     ).each do |unit_name|
      it "include a #{unit_name} unit" do
        expect(status).to have_unit(unit_name), "The #{unit_name} unit was not found."
      end
    end
  end

  describe "InfluxDB deployment" do
    it "exposes a public DNS hostname" do
      out = %x(dig +short #{status.influxdb.hostname})
      expect(out).to_not be_empty, "The InfluxDB hostname (#{status.influxdb.hostname}) was not found (no Route53?)."
      expect(out).to match(/[0-9]./), "The InfluxDB hostname (#{status.influxdb.hostname}) was not found (no Route53?)."
    end

    it "exposes a health-check endpoint accessible via HTTP GET" do
      out, json = nil, nil
      expect {
        out = %x(curl -GfsS '#{status.influxdb.healthcheck_url}' 2>&1)
      }.not_to raise_error
      expect { json = JSON.parse(out) }.not_to raise_error
      expect(json["status"]).to eq("ok")
    end

    describe "created databases" do
      def verify_json_response(db, url, out, error_message)
        expect(out).to_not include("Could not resolve host")
        expect(out).to_not include("curl:"), "Request failed for series for '#{db}' (at #{url})"
        response = nil
        expect { response = JSON.parse(out) }.not_to raise_error
        expect(response.size).to be > 0, error_message
      end

      %w(sysinfo cadvisor grafana).each do |db|
        it "include '#{db}'" do
          influxdb_query = "list series"
          url = status.influxdb.database_query_url(db, influxdb_query)
          out = %x(curl -GfsS '#{url}' 2>&1)
          verify_json_response(db, url, out, "The InfluxDB database '#{db}' contains no series.")
        end

        next if db == 'grafana' # grafana doesn't have any series until someone loads the dashboard

        it "'#{db}' exposes time-series data via GET" do
          influxdb_query = "select * from /.*/ limit 1"
          url = status.influxdb.database_query_url(db, influxdb_query)
          out = %x(curl -GfsS '#{url}' 2>&1)
          verify_json_response(db, url, out, "The InfluxDB database '#{db}' contains no data.")
        end
      end
    end
  end
end
