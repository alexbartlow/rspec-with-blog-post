Hemmingway said “write drunk, edit sober.” I like to “test in the afternoon, refactor in the morning.” I’m more clear-headed and patient doing some spec cleanup with a hot cup of coffee in my hand.

This week, I was working on some code that looked something like this:

[link](01_before.rb)

I don’t know about you, but I get pretty grumpy when my tests are 8 times longer than the method I’m trying to specify.

The first step here is to extract out the incredibly verbose method call:

[link](02_with_subject.rb)

This is a little better. I like the trick of using `.method()` to grab the method under test. But there’s still some repetition here: I have to repeat the method name a couple of times, and I have to keep typing out `described_method`. Since I’m using an explicit subject, I also don’t get to write short, punchy, self-documenting expectations. Additionally, I don’t get any hint from the spec what those parameters actually are. It would be nice to have that be self-documenting as well.

Let’s go one level deeper, by adding some methods to rspec’s example group.

[link](03_using_context_and_let.rb)

On one level, this is nicer. The subject block immediately defines what the parameters are, and we have a lot of space to add extra cases to text. However, it’s also still pretty verbose, since we have to define a new context and a new `let` for each parameter value we want to test. Let’s write a macro for that.

[link](04_using_with.rb)

Now we’re getting somewhere. Our tests are short an expressive. The only thing that annoys me about this is that weird `{ it { condition } }` block. Honestly, if I wasn’t writing a blog post about it, it’d leave it like that. But since we’re here…

[link](05_one_line_with_proxy.rb)

This might be a little excessive, but you can’t argue with results. I don’t have to include anonymous contexts, and I can use `with` as either a short-hand for a context + let to include multiple examples under it, or I can immediately call `.it` to get a one-line expectation. I’ve also added a `describe_class_method` macro, to complete the illustration.

This is the output I get, too. Totally readable:

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





 




