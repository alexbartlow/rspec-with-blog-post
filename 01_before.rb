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
    it "returns modulo when not E+" do
      expect(
        described_class.new.a_long_and_descriptive_method(
          :enterprise,
          10
        )
      ).to eq(0)

      expect(
        described_class.new.a_long_and_descriptive_method(
          :enterprise,
          8
        )
      ).to eq(8)
    end

    it "returns the value when E+" do
      expect(
        described_class.new.a_long_and_descriptive_method(
          :enterprise_plus,
          11
        )
      ).to eq(11)

      expect(
        described_class.new.a_long_and_descriptive_method(
          :enterprise_plus,
          2
        )
      ).to eq(2)
    end
  end
end
