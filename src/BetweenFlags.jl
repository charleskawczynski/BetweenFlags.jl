module BetweenFlags

push!(LOAD_PATH, "./FeaturedFuncs/src/")
push!(LOAD_PATH, "./PerFlagFuncs/src/")
export Flag
export FlagSet
export get_between_flags_flat
export get_between_flags_level
export get_between_flags_level_flat
export remove_between_flags_flat

using FeaturedFuncs
using PerFlagFuncs
using UtilityFuncs

end