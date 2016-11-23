# frozen_string_literal: true
module Loggify
  # DSL that is exposed for defining logging
  class DSL
    def initialize(klass, &block)
      @klass = klass
      @logging_layer = Module.new
      instance_eval(&block)
      klass.prepend(@logging_layer)
    end

    # Wrap a given method with logging
    # @param name [Symbol] The method to wrap
    # @yieldparam logger [Logger] The global logger instance
    # @yieldparam instance The instance the method was called on
    # @yieldparam stats [Hash] Information about the method call
    # @option stats [Array] :args The arguments the method was called with
    # @option stats [StandardError] :error The error that was raised (if any)
    # @option stats :result The return value of the method (if no exception
    #   was raised
    # @option stats [Float] :runtime The runtime for the method
    def log_method(name, &block)
      check_method_exists!(name)
      define_logging_method(
        name, method(:measure_runtime), method(:logging), &block
      )
    end

    private

    def measure_runtime
      started = Time.now
      yield_result = yield
      [yield_result, Time.now - started]
    end

    def logging(instance, args, error, result, runtime)
      yield(
        Loggify.logger, instance,
        args: args,
        error: error,
        result: result,
        runtime: runtime
      )
    end

    def define_logging_method(name, measure_runtime, logging, &dsl_block)
      @logging_layer.send(:define_method, name) do |*args, &block|
        begin
          result, runtime = measure_runtime.call { super(*args, &block) }
          logging.call(self, args, nil, result, runtime, &dsl_block)
          result
        rescue StandardError => error
          logging.call(self, args, error, nil, nil, &dsl_block)
          raise error
        end
      end
    end

    def check_method_exists!(name)
      return if @klass.instance_methods.include?(name)
      raise ArgumentError, "#{@klass} does not define method #{name}"
    end
  end
end
