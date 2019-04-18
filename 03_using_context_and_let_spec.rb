require './service'

module RspecExtensions
  def describe_instance_method(method_name, &block)
    describe "##{method_name}" do
      let(:described_method) do
        described_class.new.method(method_name)
      end

      instance_eval(&block)
    end
  end
end

RSpec::Core::ExampleGroup.send(:extend, RspecExtensions)

describe ServiceObjectUnderTest do
  describe_instance_method :a_long_and_descriptive_method do
    subject { described_method.call(subscription_class, value) }

    context do
      let(:subscription_class) { :enterprise }

      context do
        let(:value) { 10 }
        it { is_expected.to eq(0) }
      end

      context do
        let(:value) { 8 }
        it { is_expected.to eq(8) }
      end
    end

    context do
      let(:subscription_class) { :enterprise_plus }
      context do
        let(:value) { 11 }
        it { is_expected.to eq(11) }
      end

      context do
        let(:value) { 2 }
        it { is_expected.to eq(2) }
      end
    end
  end
end
