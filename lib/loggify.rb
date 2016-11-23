# frozen_string_literal: true
require 'loggify/version'
require 'loggify/dsl'

# Top level namespace
module Loggify
  # Define logging for a class/module
  # @param klass [Module] The class or module to define logging for
  def self.define(klass, &block)
    DSL.new(klass, &block)
  end
end
