lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "replicat/version"

Gem::Specification.new do |spec|
  spec.name          = "replicat"
  spec.version       = Replicat::VERSION
  spec.authors       = ["Ryo Nakamura"]
  spec.email         = ["r7kamura@gmail.com"]
  spec.description   = "Database replication helper for ActiveRecord."
  spec.homepage      = "https://github.com/r7kamura/replicat"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
