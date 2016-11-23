# frozen_string_literal: true
require 'spec_helper'

describe LogSyringe do
  it 'has a version number' do
    expect(LogSyringe::VERSION).not_to be nil
  end

  describe '.define' do
    let(:test_class) { Class.new }
    let(:dsl) { instance_double(LogSyringe::DSL) }

    before do
      allow(LogSyringe::DSL).to receive(:new) do |&block|
        dsl.instance_eval(&block)
        dsl
      end
    end

    it 'passes the given class to the dsl' do
      described_class.define(test_class) {}
      expect(LogSyringe::DSL).to have_received(:new).with(test_class)
    end

    it 'instance evals with the dsl instance' do
      context = nil
      described_class.define(test_class) do
        context = self
      end

      expect(context).to be(dsl)
    end
  end
end
