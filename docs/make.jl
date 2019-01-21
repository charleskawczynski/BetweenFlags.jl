# Base.HOME_PROJECT[] = abspath(Base.HOME_PROJECT[]) # JuliaLang/julia/pull/28625

root_dir = string(@__DIR__)
push!(LOAD_PATH, root_dir*"../src/")

using Documenter
using BetweenFlags
# using FeaturedFuncs
# using PerFlagFuncs
# using UtilityFuncs

makedocs(
  sitename = "BetweenFlags",
  format = :html,
  modules = [BetweenFlags],
  # modules = [BetweenFlags, FeaturedFuncs, PerFlagFuncs, UtilityFuncs],
  pages = Any[
  "Home" => "index.md",
  "Functions" => [
               "Functions/Greedy.md",
               "Functions/LevelBased.md",
              ],
  ]
    ],
  Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true"
  )
)

deploydocs(
           repo = "github.com/charleskawczynski/BetweenFlags.jl.git",
          )
