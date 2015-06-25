# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'role_making/version'

Gem::Specification.new do |spec|
  spec.name          = "role_making"
  spec.version       = RoleMaking::VERSION
  spec.authors       = ["javy_liu"]
  spec.email         = ["javy_liu@163.com"]
  spec.summary       = %q{for custom defined role to manage the resources}
  spec.description   = %q{A gem for resource manage based on role}
  spec.homepage      = "https://github.com/javyliu/role_making"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
