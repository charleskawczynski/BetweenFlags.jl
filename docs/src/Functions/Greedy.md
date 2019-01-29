# Greedy functions
  The greedy `BetweenFlags` functions are similar to regex pattern matching.
  The greedy `BetweenFlags` functions are useful for processing strings to, e.g., remove comments,
  where after opening a comment (e.g. triple `"`), the first instance of closing the comment must be recognized.

`BetweenFlags.get_between_flags_flat(args...)`

Where

`args = [s::String, flags_start::Vector{String}, flags_stop::Vector{String}]`

## Examples

```
  using BetweenFlags
  s = "Here is some text, and {THIS SHOULD BE GRABBED}, BetweenFlags offers a simple interface..."
  s = BetweenFlags.get_between_flags_flat(s, ["{"], ["}"])
  print(s)
{THIS SHOULD BE GRABBED}

  s = "Here is some text, and {THIS SHOULD BE GRABBED), BetweenFlags} offers a simple interface..."
  s = BetweenFlags.get_between_flags_flat(s, ["{"], ["}", ")"])
  print(s)
{THIS SHOULD BE GRABBED)
```

## Note
These functions are effectively replace-able by regex. They do, however,
provide a nice interface. The level-based functions are not, in general,
replace-able by regex (as far as I know).
