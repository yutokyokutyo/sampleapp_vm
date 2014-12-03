# -*- encoding: utf-8 -*-
# stub: serverspec 2.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "serverspec"
  s.version = "2.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gosuke Miyashita"]
  s.date = "2014-11-27"
  s.description = "RSpec tests for your servers configured by Puppet, Chef or anything else"
  s.email = ["gosukenator@gmail.com"]
  s.executables = ["serverspec-init"]
  s.files = ["bin/serverspec-init"]
  s.homepage = "http://serverspec.org/"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.9"
  s.summary = "RSpec tests for your servers configured by Puppet, Chef or anything else"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, ["~> 3.0"])
      s.add_runtime_dependency(%q<rspec-its>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_runtime_dependency(%q<specinfra>, ["~> 2.9"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, ["~> 10.1.1"])
    else
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<rspec-its>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<specinfra>, ["~> 2.9"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, ["~> 10.1.1"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<rspec-its>, [">= 0"])
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<specinfra>, ["~> 2.9"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, ["~> 10.1.1"])
  end
end
