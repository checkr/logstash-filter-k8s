Gem::Specification.new do |s|
  s.name = 'logstash-filter-k8s'
  s.version         = '0.1.0'
  s.licenses = ['MIT']
  s.summary = "This filter extracts useful kubernetes information from kubelet logfile symlinks."
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Saso Matejina"]
  s.email = 'saso@checkr.com'
  s.homepage = "https://github.com/checkr/logstash-filter-k8s"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','Gemfile','LICENSE']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_development_dependency 'logstash-devutils', '~> 0'
end
