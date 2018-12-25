# BetweenFlags.jl

A set of string processing utility functions that finds/removes text between given flags.

| **Documentation**                             | **Build Status**                                                                                                     |
|:--------------------------------------------- |:---------------------------------------------------------------------------------------------------------------------|
| [![latest][docs-latest-img]][docs-latest-url] | [![travis][travis-img]][travis-url] [![appveyor][appveyor-img]][appveyor-url] [![codecov][codecov-img]][codecov-url] |

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://charleskawczynski.github.io/BetweenFlags.jl/latest/

[travis-img]: https://travis-ci.org/charleskawczynski/BetweenFlags.jl.svg?branch=master
[travis-url]: https://travis-ci.org/charleskawczynski/BetweenFlags.jl

[appveyor-img]: https://ci.appveyor.com/api/projects/status/ca6lgtt9f8e42o4f?svg=true
[appveyor-url]: https://ci.appveyor.com/project/charleskawczynski/betweenflags-jl

[codecov-img]: https://codecov.io/gh/charleskawczynski/BetweenFlags.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/charleskawczynski/BetweenFlags.jl

## Installation

To install, use

`] add BetweenFlags`

## General form of features

`BetweenFlags` offers some regex-like features of finding,
and removing, text between given flags. There are several
versions, as this problem often arises in several contexts.
Most are og the following form:

```
BetweenFlags.get(args...)
BetweenFlags.remove(args...)
```

Where

`args = [s::String, flags_start::Vector{String}, flags_stop::Vector{String}]`


## Greedy functions
  The greedy version of `BetweenFlags` is needed for processing
  things like comments, where after opening a comment, the first
  instance of closing the comment must be recognized.

###  Examples:

```
using BetweenFlags
s = "Here is some text, and {THIS SHOULD BE GRABBED}, BetweenFlags offers a simple interface..."
s = BetweenFlags.get(s, ["{"], ["}"])
print(s)
{THIS SHOULD BE GRABBED}
s = "Here is some text, and {THIS SHOULD BE GRABBED), BetweenFlags} offers a simple interface..."
s = BetweenFlags.get(s, ["{"], ["}", ")"])
print(s)
{THIS SHOULD BE GRABBED)
```

## Level-based functions
  The level-based version of BetweenFlags is needed for things
  like finding functions, where then "end" of a function should
  not be confused with the end of an "if" statement inside the
  function. Therefore, the "level" corresponding to that function
  should be zero both on the opening and closing of the function.

###  Examples:

