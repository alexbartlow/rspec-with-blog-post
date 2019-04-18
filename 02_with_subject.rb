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

describe ServiceObjectUnderTest do
  describe '.a_long_and_descriptive_method' do
    subject(:described_method) do
      described_class.new.method(:a_long_and_descriptive_method)
    end

    it "returns modulo when not E+" do
      expect(
        described_method.call(:enterprise, 10)
      ).to eq(0)

      expect(
        described_method.call(:enterprise, 8)
      ).to eq(8)
    end

    it "returns the value when E+" do
      expect(
        described_method.call(:enterprise_plus, 11)
      ).to eq(11)

      expect(
        described_method.call(:enterprise_plus, 2)
      ).to eq(2)
    end
  end
end
