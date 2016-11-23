# frozen_string_literal: true
require 'spec_helper'
require 'loggify/dsl'
require 'logger'
require 'timecop'

describe Loggify::DSL do
  class TestError < StandardError; end

  let(:logger) { instance_double(Logger) }
  let(:test_class) do
    Class.new do
      attr_accessor :log_calls

      def initialize
        @log_calls = []
      end

      def foo(bar)
        Timecop.travel(1)
        bar
      end

      def bar
        raise TestError, 'raise coming through'
      end
    end
  end

  around { |example| Timecop.freeze { example.run } }

  describe '.new' do
    it 'instance evals the given block' do
      context = nil
      described_class.new(test_class) do
        context = self
      end

      expect(context).to be_kind_of(described_class)
    end
  end

  describe '#log_method' do
    let(:instance) { test_class.new }
    let(:log_calls) { instance.log_calls }
    let(:log_call) { log_calls.last }
    let(:stats) { log_call[2] }

    before do
      allow(Loggify).to receive(:logger).and_return(logger)
      described_class.new(test_class) do
        log_method(:foo) do |logger, instance, stats|
          instance.log_calls << [logger, instance, stats]
        end

        log_method(:bar) do |logger, instance, stats|
          instance.log_calls << [logger, instance, stats]
        end
      end

      instance.foo(:bar)
    end

    it 'calls the block when the logged method is called' do
      2.times { instance.foo(:bar) } # one time already in before block
      expect(log_calls.size).to eq(3)
    end

    it 'yields the logger to the block' do
      expect(log_call[0]).to be(logger)
    end

    it 'yields the instance to the block' do
      expect(log_call[1]).to be(instance)
    end

    it 'yields a stats hash to the block' do
      expect(log_call[2]).to be_kind_of(Hash)
    end

    it 'yields the args the method was called with' do
      expect(stats[:args]).to eq([:bar])
    end

    it 'yields any raised error to the block' do
      begin
        instance.bar
      rescue
        expect(stats[:error]).to be_kind_of(TestError)
      end
    end

    it 'yields the result of the method' do
      expect(stats[:result]).to eq(:bar)
    end

    it 'yields the runtime of the method' do
      expect(stats[:runtime]).to be_within(0.01).of(1)
    end

    it 'does not change the return value of the original method' do
      expect(instance.foo(:bar)).to eq(:bar)
    end

    it 'does not rescue exceptions' do
      expect { instance.bar }.to raise_error(TestError)
    end

    it 'raises if trying to wrap a non-existing method' do
      expect { described_class.new(test_class) { log_method(:foobar) {} } }.to(
        raise_error(ArgumentError)
      )
    end
  end
end
