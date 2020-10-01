# BetweenFlags.jl

BetweenFlags.jl is a text-grepping tool that can be used with greedy or scope-aware configurations.

## Greedy

```@example
using BetweenFlags

flag_set = FlagSet([
            FlagPair(
                Flag("{", [""], [""], flag_type=StartType()),
                Flag("}", [""], [""])
            )
          ]);

text = "Foo, {bar {foobar} baz}, foobaz...";

token_stream = BetweenFlags.tokenize(text, flag_set);

BetweenFlags.get_string(text, token_stream, "{-}")
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

token_stream = BetweenFlags.tokenize(text, flag_set);

BetweenFlags.get_string(text, token_stream, "{-}")
"{bar {foobar} baz}"
```
