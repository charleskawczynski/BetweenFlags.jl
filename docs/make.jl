Base.HOME_PROJECT[] = abspath(Base.HOME_PROJECT[]) # JuliaLang/julia/pull/28625
push!(LOAD_PATH,"../")
push!(LOAD_PATH,"../src/")

using Documenter, BetweenFlags

makedocs(
  sitename = "BetweenFlags",
  format = :html,
  modules = [BetweenFlags, PerFlagFuncs],
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
