####
#### Flags
####

export StartFlag, StopFlag, FlagPair, FlagSet
export GreedyType, ScopeType
export TokenStream

abstract type AbstractGrepType end
struct ScopeType <: AbstractGrepType end
struct GreedyType <: AbstractGrepType end

abstract type AbstractFlag{GT<:AbstractGrepType} end

"""
    StartFlag(flag::String,
              flag_boundaries_left::Vector{String},
              flag_boundaries_right::Vector{String})

A "start" flag that BetweenFlags looks for to denote
the start position of a given scope.
"""
struct StartFlag{GT} <: AbstractFlag{GT}
  flag::String
  flag_boundaries_left::Vector{String}
  flag_boundaries_right::Vector{String}
  trigger::Dict{Tuple,String}
end
function StartFlag(flag::S,
  flag_boundaries_left=S[],
  flag_boundaries_right=S[];
  grep_type::AbstractGrepType=GreedyType()
  ) where {S<:AbstractString, GT<:AbstractGrepType}
  trigger = Dict{Tuple,String}()
  for left in flag_boundaries_left
    for right in flag_boundaries_right
      trigger[(left,right)] = string(left, flag, right)
    end
  end
  isempty(trigger) && (trigger[("","")] = flag)
  return StartFlag{typeof(grep_type)}(flag, flag_boundaries_left,
        flag_boundaries_right, trigger)
end

"""
    StopFlag(flag::String,
              flag_boundaries_left::Vector{String},
              flag_boundaries_right::Vector{String})

A "stop" flag that BetweenFlags looks for to denote
the stop position of a given scope.
"""
struct StopFlag{GT} <: AbstractFlag{GT}
  flag::String
  flag_boundaries_left::Vector{String}
  flag_boundaries_right::Vector{String}
  trigger::Dict{Tuple,String}
end
function StopFlag(flag::S,
  flag_boundaries_left=S[],
  flag_boundaries_right=S[];
  grep_type::AbstractGrepType=GreedyType()
  ) where {S<:AbstractString}
  trigger = Dict{Tuple,String}()
  for left in flag_boundaries_left
    for right in flag_boundaries_right
      trigger[(left,right)] = string(left, flag, right)
    end
  end
  isempty(trigger) && (trigger[("","")] = flag)
  return StopFlag{typeof(grep_type)}(flag, flag_boundaries_left,
        flag_boundaries_right, trigger)
end

# TODO: resolve inconsistency between
# grep_type of flag and flag pair, as
# these are easily set different from
# each other.
grep_type(::AbstractFlag{T}) where T = T

####
#### FlagPair
####

"""
    FlagPair(start::Flag, stop::Flag)

A flag pair that defines the start and stop of
the substring of interest.

```julia
julia>
using BetweenFlags
# find: ["\\nfunction", " function", ";function"]
start_flag = StartFlag("function",
                  ["\\n", "\\s", ";"],
                  ["\\n", "\\s"])
# find: ["\\nend", " end", ";end"]
stop_flag = StopFlag("end",
                 ["\\n", "\\s", ";"],
                 ["\\n", "\\s", ";"])
flag_pair = FlagPair{ScopeType}(start_flag, stop_flag)
```
"""
struct FlagPair{FPT}
  start::StartFlag
  stop::StopFlag
  ID::String
  function FlagPair{FPT}(
    start::StartFlag,
    stop::StopFlag
    ) where {FPT<:Union{ScopeType,GreedyType}}
    return new{FPT}(start, stop, start.flag*"-"*stop.flag)
  end
end
FlagPair(start, stop) = FlagPair{GreedyType}(start, stop)

grep_type(::FlagPair{T}) where T = T

struct FlagSet{FP}
  flag_pairs::Vector{FP}
end

"""
    TokenStream

A token stream, containing
 - `flag_set` a `FlagSet`
 - `code` a string of code to be tokenized
 - `token_stream` a token stream (dict)
    whose keys are the flag IDs,
    and whose values are vectors of `Int`s
    indicating the nestedness of the flag.
"""
struct TokenStream{FS,C,TS}
  flag_set::FS
  code::C
  token_stream::TS
end
