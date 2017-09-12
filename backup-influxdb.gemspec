# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "backup/influxdb/version"

Gem::Specification.new do |spec|
  spec.name          = "backup-influxdb"
  spec.version       = Backup::Influxdb::VERSION
  spec.authors       = ["Chris Gunther"]
  spec.email         = ["chris@room118solutions.com"]

  spec.summary       = %q{Add support for InfluxDB to backup}
  spec.description   = %q{Add support for InfluxDB to backup}
  spec.homepage      = "http://github.com/cgunther/backup-influxdb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "backup", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
