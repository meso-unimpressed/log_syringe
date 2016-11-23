# frozen_string_literal: true
require 'loggify/version'
require 'loggify/dsl'

# Top level namespace
module Loggify
  # Define logging for a class/module
  # @param klass [Module] The class or module to define logging for
  # @example
  #   Loggify.define(MyClass) do
  #     log_method(:some_method) do |logger, instance, stats|
  #       logger.info("some method called on #{instance} with #{stats[:args]}")
  #     end
  #   end
  def self.define(klass, &block)
    DSL.new(klass, &block)
  end
end
