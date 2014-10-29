require 'pathname'
require 'uri'
require 'ipaddr'
require 'json'
require_relative 'cloud_status'

status = CloudStatus.new('terraform/cluster_values.tfvars', 'cloud.nlab.io')

RSpec.describe CloudStatus do
  it "should have an environment name set in terraform/cluster_values.tfvars" do
    expect(status.cluster_values_filepath).to exist,
      "#{status.cluster_values_filepath} file does not exist. Please run new_cluster_values from the terraform directory."
    expect(status.environment_name).to_not be_nil
    expect(status.environment_name).to match(/[a-z]{5}/)
  end

  it "should have FLEETCTL_TUNNEL environment variable set for local tests", focus: true do
    expect { IPAddr.new(ENV['FLEETCTL_TUNNEL']) }.not_to raise_error,
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

  describe "InfluxDB" do
    it "exposes a public DNS hostname" do
      out = %x(dig +short #{status.influxdb_hostname})
      expect(out).to_not be_empty, "The InfluxDB hostname (#{status.influxdb_hostname}) was not found (no Route53?)."
      expect(out).to match(/[0-9]./), "The InfluxDB hostname (#{status.influxdb_hostname}) was not found (no Route53?)."
    end

    it "can GET the health endpoint" do
      out, json = nil, nil
      cmd = "curl -GfsS 'http://#{status.influxdb_hostname}:8086/ping' 2>&1"
      expect { out = %x(#{cmd}) }.not_to raise_error
      expect { json = JSON.parse(out) }.not_to raise_error
      expect(json["status"]).to eq("ok")
    end

    describe "databases" do
      %W(sysinfo cadvisor grafana).each do |db|
        it "can verify that the #{db} database has been created" do
          influx_query = "list series"
          query = URI.encode_www_form("u" => "root", "p" => "root", "q" => influx_query)
          url = URI::HTTP.build([nil, status.influxdb_hostname, 8086, "/db/#{db}/series", query, nil])
          cmd = "curl -GfsS '#{url}' 2>&1"
          out = %x(#{cmd})
          expect(out).to_not include("curl:"), "Request failed for series for '#{db}' (at #{url})"
          expect(out).to_not include("Could not resolve host")
          response = nil
          expect { response = JSON.parse(out) }.not_to raise_error
          expect(response.size).to be > 0, "The influxdb #{db} database contains no series."
        end

        next if db == 'grafana'

        it "can GET time-series data from the #{db} database" do
          influx_query = "select * from /.*/ limit 1"
          query = URI.encode_www_form("u" => "root", "p" => "root", "q" => influx_query)
          url = URI::HTTP.build([nil, status.influxdb_hostname, 8086, "/db/#{db}/series", query, nil])
          cmd = "curl -GfsS '#{url}' 2>&1"
          out = %x(#{cmd})
          expect(out).to_not include("curl:"), "Request failed for series for '#{db}' (at #{url})"
          expect(out).to_not include("Could not resolve host")
          response = nil
          expect { response = JSON.parse(out) }.not_to raise_error
          expect(response.size).to be > 0, "The influxdb #{db} database contains no series."
        end
      end
    end
  end
end
