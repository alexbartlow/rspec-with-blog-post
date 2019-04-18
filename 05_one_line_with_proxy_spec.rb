require './service'
require './final_rspec_with_extensions'

describe ServiceObjectUnderTest do
  describe_instance_method :a_long_and_descriptive_method do
    method_parameters(:subscription_class, :value)

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
