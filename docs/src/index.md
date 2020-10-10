# BetweenFlags.jl

BetweenFlags.jl is a text-grepping tool that can be used with greedy or scope-aware configurations.

## Greedy

```@example
using BetweenFlags

flag_set = FlagSet([
            FlagPair{GreedyType}(
                StartFlag("{", [""], [""]),
                StopFlag("}", [""], [""])
            )
          ]);

text = "Foo, {bar {foobar} baz}, foobaz...";

token_stream = TokenStream(text, flag_set);

token_stream("{-}")
```

## Scope-aware

```@example
using BetweenFlags

flag_set = FlagSet([
            FlagPair{ScopeType}(
                StartFlag("{", [""], [""]),
                StopFlag("}", [""], [""])
            )
          ]);

text = "Foo, {bar {foobar} baz}, foobaz...";

token_stream = TokenStream(text, flag_set);

token_stream("{-}")
```
