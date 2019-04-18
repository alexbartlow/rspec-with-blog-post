require './service'

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
