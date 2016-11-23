# frozen_string_literal: true
module LogSyringe
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
    # @yieldparam stats [Hash] Information about the method call.
    #   It contains the following information: +:args [Array]+ the arguments the
    #   method was called with, +:error [Error]+ the error that was
    #   raised (if any), +:result+ the return value of the method
    #   (if no exception was raised), +:runtime+ the runtime for the method
    #   (if no exception was raised).
    # @example
    #   log_method(:some_method) do |logger, instance, stats|
    #     logger.info(
    #       "some_method called on #{instance} with args #{stats[:args]}. " \
    #       "runtime: #{stats[:runtime]}"
    #     )
    #   end
    def log_method(name, &block)
      visibility = visibility(name)
      define_logging_method(
        name, method(:measure_runtime), method(:logging), &block
      )
      @logging_layer.send(visibility, name)
    end

    private

    def measure_runtime
      started = Time.now
      yield_result = yield
      [yield_result, Time.now - started]
    end

    def logging(instance, args, error, result, runtime)
      yield(
        LogSyringe.logger, instance,
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

    def visibility(name)
      result = [:public, :protected, :private].find do |visibility|
        @klass.send(:"#{visibility}_method_defined?", name)
      end

      unless result
        raise ArgumentError, "#{@klass} does not define method #{name}"
      end

      result
    end
  end
end
