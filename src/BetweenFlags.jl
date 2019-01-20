module BetweenFlags

root_dir = string(@__DIR__)
push!(LOAD_PATH, root_dir*"./FeaturedFuncs/src/")
push!(LOAD_PATH, root_dir*"./PerFlagFuncs/src/")
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