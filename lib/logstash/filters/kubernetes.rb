# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'json'

# This filter plugin allows you extract Pod, Namespace, etc from kubernetes.
# The way this filter works is very simple. It looks at an event field which
# contains full path to kubelet created symlinks to docker container logs and
# extracts useful information from a symlink name. No access to Kubernetes API
# is required.
class LogStash::Filters::Kubernetes < LogStash::Filters::Base

  # This is how you configure this filter from your Logstash config.
  #
  # Example:
  # [source,ruby]
  # input {
  #   file {
  #     # Path to kubelet symlinks to docker logs, by default, symlinks look like
  #     # /var/lib/docker/containers/*/*-json.log
  #     path => "/var/lib/docker/containers/*/*-json.log"
  #   }
  # }
  #
  # filter {
  #   kubernetes {
  #     source => "path"
  #     target => "kubernetes"
  #   }
  # }
  #
  config_name "kubernetes"

  # The source field name which contains full path to kubelet log file.
  config :source, :validate => :string, :default => "path"

  # The target field name to write event kubernetes metadata.
  config :target, :validate => :string, :default => "kubernetes"


  public
  def register
    @cached = Hash.new
  end

  public
  def filter(event)
    if @source
      parts = event[@source].split(File::SEPARATOR)
      container_id = parts.last.gsub(/-json.log$/, '')

      unless @cached.has_key?(container_id)
        config_path = parts[0...-1].push("config.v2.json").join(File::SEPARATOR) 
        config_json = File.read(config_path)
        config = JSON.parse(config_json)
        return if config.empty?

        kubernetes = {}
        kubernetes['pod'] = config["Config"]["Labels"]["io.kubernetes.pod.name"]
        kubernetes['namespace'] =  config["Config"]["Labels"]["io.kubernetes.pod.namespace"]
        kubernetes['container_name'] = config["Config"]["Labels"]["io.kubernetes.container.name"]
        kubernetes['container_id'] = container_id
        kubernetes['image'] = config["Config"]["Image"]
        kubernetes['container_hash'] = config["Config"]["Labels"]["io.kubernetes.container.hash"]

        @cached[container_id] = kubernetes
      end
      
      # We do not care about POD log files
      return if @cached[container_id]["container_name"] == "POD"
      
      event[@target] = @cached[container_id]
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end
end
