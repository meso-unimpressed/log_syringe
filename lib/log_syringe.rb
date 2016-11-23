# frozen_string_literal: true
require 'log_syringe/version'
require 'log_syringe/dsl'

# Top level namespace
module LogSyringe
  class << self
    # The logger to be passed to log_method blocks
    attr_accessor :logger

    # Define logging for a class/module
    # @param klass [Module] The class or module to define logging for
    # @example
    #   LogSyringe.define(MyClass) do
    #     log_method(:some_method) do |logger, instance, stats|
    #       logger.info(
    #         "some method called on #{instance} with #{stats[:args]}"
    #       )
    #     end
    #   end
    def define(klass, &block)
      DSL.new(klass, &block)
    end
  end
end
