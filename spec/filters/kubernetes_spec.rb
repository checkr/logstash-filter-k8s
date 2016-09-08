require 'spec_helper'
require "logstash/filters/kubernetes"

describe LogStash::Filters::Kubernetes do
  describe "Split path into kubernetes key-value pairs." do
    let(:json_file) do 
      File.read(__dir__ + "/../fixtures/container-json.log")
    end
    let(:config) do <<-CONFIG
      filter {
        kubernetes {
          source => "path"
        }
      }
    CONFIG
    end

    sample("path" => "/var/lib/docker/containers/c4d8a8c986fac347a93b085a0677d0672b2caaba7845a513d0ba9b5176fd1b53/c4d8a8c986fac347a93b085a0677d0672b2caaba7845a513d0ba9b5176fd1b53-json.log") do
      allow(File).to receive(:read).and_return(json_file)
      insist { subject["kubernetes"] } == {"pod"=>"checkr-dashboard-deployment-1223682821-04fkp", "namespace"=>"default", "container_name"=>"checkr-dashboard", "container_id"=>"c4d8a8c986fac347a93b085a0677d0672b2caaba7845a513d0ba9b5176fd1b53", "image"=>"checkr/dashboard:saso", "container_hash"=>"8c095b3d"} 
    end
  end
end

describe LogStash::Filters::Kubernetes do
  describe "Set target field name." do
    let(:json_file) do 
      File.read(__dir__ + "/../fixtures/container-json.log")
    end
    let(:config) do <<-CONFIG
      filter {
        kubernetes {
          source => "path"
          target => "foobar"
        }
      }
    CONFIG
    end

    sample("path" => "/var/lib/docker/containers/c4d8a8c986fac347a93b085a0677d0672b2caaba7845a513d0ba9b5176fd1b53/c4d8a8c986fac347a93b085a0677d0672b2caaba7845a513d0ba9b5176fd1b53-json.log") do
      allow(File).to receive(:read).and_return(json_file)
      insist { subject["foobar"] } == {"pod"=>"checkr-dashboard-deployment-1223682821-04fkp", "namespace"=>"default", "container_name"=>"checkr-dashboard", "container_id"=>"c4d8a8c986fac347a93b085a0677d0672b2caaba7845a513d0ba9b5176fd1b53", "image"=>"checkr/dashboard:saso", "container_hash"=>"8c095b3d"}
    end
  end
end

describe LogStash::Filters::Kubernetes do
  describe "Skip parsing empty POD event." do
    let(:json_file) do 
      File.read(__dir__ + "/../fixtures/pod-json.log")
    end
    let(:config) do <<-CONFIG
      filter {
        kubernetes {
          source => "path"
        }
      }
    CONFIG
    end

    sample("path" => "/var/lib/docker/containers/c4d8a8c986fac347a93b085a0677d0672b2caaba7845a513d0ba9b5176fd1b53/c4d8a8c986fac347a93b085a0677d0672b2caaba7845a513d0ba9b5176fd1b53-json.log") do
      allow(File).to receive(:read).and_return(json_file)
      insist { subject["kubernetes"] } == nil
    end
  end
end
