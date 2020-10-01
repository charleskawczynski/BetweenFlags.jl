####
#### Flag
####

export Flag, FlagPair, FlagSet
export StartType, GreedyType, StopType

abstract type AbstractFlagType end
struct StartType <: AbstractFlagType end
struct GreedyType <: AbstractFlagType end
struct StopType <: AbstractFlagType end

"""
    Flag(flag::String,
         flag_boundaries_left::Vector{String},
         flag_boundaries_right::Vector{String})

A flag that BetweenFlags looks for to denote
the start/stop position of a given scope.
The flag boundaries need only be unique
since every permutation of left and right
flag boundaries are taken to determine scopes.

```julia
julia>
using BetweenFlags
# find: ["\\nfunction", " function", ";function"]
start_flag = Flag("function",
                  ["\\n", "\\s", ";"],
                  ["\\n", "\\s"],
                  StartType())
# find: ["\\nend", " end", ";end"]
stop_flag = Flag("end",
                 ["\\n", "\\s", ";"],
                 ["\\n", "\\s", ";"],
                 StopType())
```
"""
struct Flag{T}
  flag :: String
  flag_boundaries_left :: Vector{String}
  flag_boundaries_right :: Vector{String}
  trigger :: Vector{String}
  flag_type::T
  function Flag(
    flag::S,
    flag_boundaries_left=S[],
    flag_boundaries_right=S[];
    flag_type::T=GreedyType()
    ) where {S<:AbstractString, T<:AbstractFlagType}
    trigger = Vector{String}()
    for left in flag_boundaries_left
      for right in flag_boundaries_right
        push!(trigger, string(left, flag, right))
      end
    end
    if isempty(trigger)
      push!(trigger, flag)
    end
    return new{T}(flag,
      flag_boundaries_left,
      flag_boundaries_right,
      trigger,
      flag_type
      )
  end
end

flag_type(::Flag{T}) where T = T

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
start_flag = Flag("function",
                  ["\\n", "\\s", ";"],
                  ["\\n", "\\s"],
                  StartType())
# find: ["\\nend", " end", ";end"]
stop_flag = Flag("end",
                 ["\\n", "\\s", ";"],
                 ["\\n", "\\s", ";"],
                 StopType())
flag_pair = FlagPair(start_flag, stop_flag)
```
"""
struct FlagPair{A,B}
  start :: Flag{A}
  stop :: Flag{B}
  ID  :: String
  function FlagPair(
    start::TA,
    stop::TB
    ) where {TA<:Union{Flag{StartType}},
             TB<:Union{Flag{StopType},Flag{GreedyType}}}
  return new{
  flag_type(start),
  flag_type(stop)}(
    start,
    stop,
    start.flag*"-"*stop.flag)
  end
end

struct FlagSet{FP}
  flag_pairs::Vector{FP}
end

function (flag_set::FlagSet)(key::String, trigger)
  flag_pairs.stop.trigger
end
