using Documenter
push!(LOAD_PATH,"../src/")
using BetweenFlags

makedocs(
  sitename = "BetweenFlags",
  format = :html,
  modules = [BetweenFlags, PerFlagFuncs],
  pages = [
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
