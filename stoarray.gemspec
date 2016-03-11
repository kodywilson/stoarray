# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stoarray/version'
dev_deps = %w{bundler coveralls guard guard-rspec pry pry-nav pry-remote rake rspec}

Gem::Specification.new do |spec|
  spec.name          = "stoarray"
  spec.version       = Stoarray::VERSION
  spec.date          = "2016-02-02"
  spec.authors       = ["Kody Wilson"]
  spec.email         = ["kodywilson@gmail.com"]
  spec.summary       = %q{Storage array Ruby sdk}
  spec.description   = %q{Interact with storage array api using Ruby}
  spec.homepage      = "https://github.com/kodywilson/stoarray"
  spec.license       = "MIT"

  # This gem will work with 2.0.0 or greater...
  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  dev_deps.each do |deppy|
    spec.add_development_dependency deppy
  end

  spec.add_runtime_dependency 'rest-client'

end
