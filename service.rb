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