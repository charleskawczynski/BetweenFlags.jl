# BetweenFlags.jl

BetweenFlags.jl is a text-grepping tool that can be used with greedy or scope-aware configurations.

## Greedy

```@example
using BetweenFlags

flag_set = FlagSet([
            FlagPair(
                Flag("{", [""], [""], flag_type=StartType()),
                Flag("}", [""], [""], flag_type=GreedyType())
            )
          ]);

text = "Foo, {bar {foobar} baz}, foobaz...";

token_stream = TokenStream(text, flag_set);

token_stream("{-}")
"{bar {foobar}"
```

## Scope-aware

```@example
using BetweenFlags

flag_set = FlagSet([
            FlagPair(
                Flag("{", [""], [""], flag_type=StartType()),
                Flag("}", [""], [""], flag_type=StopType())
            )
          ]);

text = "Foo, {bar {foobar} baz}, foobaz...";

token_stream = TokenStream(text, flag_set);

token_stream("{-}")
"{bar {foobar} baz}"
```
