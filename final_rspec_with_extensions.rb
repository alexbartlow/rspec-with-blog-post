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

  def method_parameters(*parameters)
    let :method_called_with_parameters do
      parameters.inject(described_method.curry) do |curry, parameter|
        curry.call(send(parameter))
      end
    end

    subject { method_called_with_parameters }
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