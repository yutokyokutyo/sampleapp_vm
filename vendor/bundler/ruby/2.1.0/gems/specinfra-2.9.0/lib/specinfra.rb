require 'specinfra/version'
require 'specinfra/helper'
require 'specinfra/backend'
require 'specinfra/command'
require 'specinfra/command_factory'
require 'specinfra/command_result'
require 'specinfra/configuration'
require 'specinfra/runner'
require 'specinfra/processor'

include Specinfra

module Specinfra
  class << self
    def configuration
      Specinfra::Configuration
    end

    def command
      Specinfra::CommandFactory
    end

    def backend
      type = Specinfra.configuration.backend
      if type.nil?
        warn "No backend type is specified. Fall back to :exec type."
        type = :exec
      end
      eval "Specinfra::Backend::#{type.to_s.to_camel_case}.instance"
    end
  end
end

if defined?(RSpec)
  RSpec.configure do |c|
    c.include(Specinfra::Helper::Configuration)
    c.add_setting :os,            :default => nil
    c.add_setting :host,          :default => nil
    c.add_setting :ssh,           :default => nil
    c.add_setting :scp,           :default => nil
    c.add_setting :sudo_password, :default => nil
    c.add_setting :winrm,         :default => nil
    c.add_setting :architecture,  :default => :x86_64
    Specinfra.configuration.defaults.each { |k, v| c.add_setting k, :default => v }
    c.before :each do
      example = RSpec.respond_to?(:current_example) ? RSpec.current_example : self.example
      Specinfra.backend.set_example(example)
    end
  end
end

class Class
  def subclasses
    result = []
    ObjectSpace.each_object(Class) do |k|
      result << k if k < self
    end
    result
  end
end

class String
  def to_snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def to_camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end
