# before - initial code:

require 'rspec/autorun'

class ServiceObjectUnderTest
  # Obviously oversimplified logic. Not the point of this exercise
  def a_long_and_descriptive_method(subscription_class, value)
    if subscription_class == :enterprise_plus
      value
    else
      value % 10
    end
  end
end

module RspecWithExtensions
  def describe_class_method(method_name, &block)
    describe ".#{method_name}" do
      let(:described_method) do
        described_class.method(method_name)
      end

      instance_eval(&block)
    end
  end

  def describe_instance_method(method_name, &block)
    describe "##{method_name}" do
      let(:described_method) do
        described_class.new.method(method_name)
      end

      instance_eval(&block)
    end
  end

  class WithProxy
    def initialize(example_group, lets)
      @example_group = example_group
      @lets = lets
    end

    def context_description
      @lets.map{ |k, v| "#{k}=#{v}"}.join(',')
    end

    def call(&block)
      lets = @lets
      @example_group.context("with #{context_description}") do
        lets.each do |lk, lv|
          let(lk) { lv }
        end

        instance_eval(&block)
      end
    end

    def it(&block)
      call { it(&block) }
    end
  end

  def with(lets, &block)
    proxy = WithProxy.new(self, lets)

    if block
      proxy.call(&block)
    else
      proxy
    end
  end
end

RSpec::Core::ExampleGroup.send(:extend, RspecWithExtensions)

describe ServiceObjectUnderTest do
  describe_instance_method :a_long_and_descriptive_method do
    subject { described_method.call(subscription_class, value) }

    with subscription_class: :enterprise do
      with(value: 10).it { is_expected.to eq(0) }
      with(value: 8).it { is_expected.to eq(8) }
    end

    with subscription_class: :enterprise_plus do
      with(value: 11).it { is_expected.to eq(11) }
      with(value: 2).it { is_expected.to eq(2) }
    end
  end
end
