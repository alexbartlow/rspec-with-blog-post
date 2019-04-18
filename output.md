

Like most of America, lately I've been trying Marie Kondo's method of tidying up around my house. Around the Aha! codebase, I've likewise been trying to get my specs to spark joy. 
This week, I was working on some code that looked something like this:

```ruby
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
```

I was hacking some specs together for them, and came up with something like this:
```ruby
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

```

I don’t know about you, but I get pretty grumpy when my tests are 8 times longer than the method I’m trying to specify. Not exactly joyful.

### Don't repeat `described_class` everywhere

The first step here is to extract out the incredibly verbose method call:

```ruby
require './service'

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

```

This is a little better. I like the trick of using `.method()` to grab the method under test. Even just this small enhancement gives me a lot less typing.

But there’s still some repetition here: I have to repeat the method name a couple of times, and I have to keep typing out `described_method`. Since I’m using an explicit subject, I also don’t get to write short, punchy, self-documenting expectations. Additionally, I don’t get any hint from the spec what those parameters actually are. It would be nice to have that be self-documenting as well.

### Writing our own descriptors

Let’s go one level deeper, by adding some methods to rspec’s example group.

```ruby
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

```

We're inserting our own macro here to avoid repeating the name of the method (in case we want to change it in the future). It also gives us a subject block that immediately tells us the method signature. While it's not obvious with this example, my experience is that using `context` and `let` also makes it really, really easy to add new test cases. If I think of some new edge cases that I want to test, I just have to drop a new expectation into the right section of the file, with all the other variables that are already put together.

### A better way to add context

Our code is still pretty verbose, since we have to define a new context and a new `let` for each parameter value we want to test. Let’s write a macro for that. We'll add this to our RspecExtensions module:

```ruby
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

```

Now, our specs look like this:

```ruby
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

```

Now we’re getting somewhere. Our tests are short and expressive, and basically all the boilerplate is gone.

### Everything is better with curry

Having the subject there is nice, but now I'm thinking it could be better. What if instead of telling rspec that my subject is the invocation of my method with certain parameters, I could just tell it what those parameters were?

```ruby
  def method_parameters(*parameters)
    let :method_called_with_parameters do
      parameters.inject(described_method.curry) do |curry, parameter|
        curry.call(send(parameter))
      end
    end

    subject { method_called_with_parameters }
  end

```

The `curry` method doesn't show up outside of code-golf often but it's pretty cool. It allows you to do [partial application](https://en.wikipedia.org/wiki/Partial_application) in ruby. As a result - I don't have to declare my subject explicitly anymore. I just have to call `method_parameters(subscription_class, value)`, and everything just works.

The way I've written it here, there's also `let(:method_called_with_parameters)`. This is so I can do something like this, if I'm testing for side effects:

```ruby
expect { method_called_with_parameters }.to change(Feature. :count).by(1)
```

I'm also not crazy about that weird `{ it { condition } }` block ; it looks like a busted handlebars template. Honestly, if I wasn’t writing a blog post about it, it’d leave as it is. But since we’re here, let's refactor our `with` method. I want to be able to give it a block (in which case it should do exactly what it does now), or call `.it` directly on it to give it a one-line expectation. The only real way to do that is to use a proxy object:

```ruby
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

```

### The big pay-off

With that little bit of weirdness out of the way, check out our end result:

```ruby
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

```

Now THIS sparks some joy. I don’t have to include anonymous contexts, and I can use `with` in two different, powerful ways. I can use it as a combination `context` and `let` to introduce multiple examples. I can also immediately call `.it` to get a one-line expectation with an implicit subject.

I get a beautiful, self-evident description of what the method should do in a variety of circumstances. I'll admit, I've never really been a TDD guy before - but something like this makes TDD a snap. Writing these specifications is quick, clean, and painless. You can totally picture putting a few of these specifications together 

This is the output I get from running the above example, which is also very readable.

```
rspec --format=documentation 05_one_line_with_proxy.rb

ServiceObjectUnderTest
  #a_long_and_descriptive_method
    with subscription_class=enterprise
      with value=10
        should eq 0
      with value=8
        should eq 8
    with subscription_class=enterprise_plus
      with value=11
        should eq 11
      with value=2
        should eq 2
```

### Conclusion

Hacking together the improvements to the specs above didn't take that long, and now we have some powerful new tools for writing clean, joyful specs. They're faster to write, easier to read, and easier to add to in the future. Take some time to optimize your code for developer happiness, and you may just find a huge productivity boost as a result.

If you want to find the whole extension that I wrote for this post, you can get it over at [my github.](https://github.com/alexbartlow/rspec-with-blog-post)