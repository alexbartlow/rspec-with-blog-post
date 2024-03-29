require './service'

module RspecWithExtensions
  def describe_instance_method(method_name, &block)
    describe "##{method_name}" do
      let(:described_method) do
        described_class.new.method(method_name)
      end

      instance_eval(&block)
    end
  end

  def with(lets, &block)
    context_description = lets.map{|k, v| "#{k}=#{v}"}.join(',')
    context("with #{context_description}") do
      lets.each do |lk, lv|
        let(lk) { lv }
      end

      instance_eval(&block)
    end
  end
end

RSpec::Core::ExampleGroup.send(:extend, RspecWithExtensions)

describe ServiceObjectUnderTest do
  describe_instance_method :a_long_and_descriptive_method do
    subject { described_method.call(subscription_class, value) }

    with subscription_class: :enterprise do
      with(value: 10) { it { is_expected.to eq(0) } }
      with(value: 8) { it { is_expected.to eq(8) } }
    end

    with subscription_class: :enterprise_plus do
      with(value: 11) { it { is_expected.to eq(11) } }
      with(value: 2) { it { is_expected.to eq(2) } }
    end
  end
end
