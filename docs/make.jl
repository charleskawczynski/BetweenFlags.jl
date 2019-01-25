# Base.HOME_PROJECT[] = abspath(Base.HOME_PROJECT[]) # JuliaLang/julia/pull/28625

push!(LOAD_PATH, "../")
using Documenter
using BetweenFlags

makedocs(
  sitename = "BetweenFlags",
  doctest = false,
  strict = false,
  format = Documenter.HTML(),
  modules = [BetweenFlags],
  pages = Any[
  "Home" => "index.md",
  "Functions" => [
               "Functions/Greedy.md",
               "Functions/LevelBased.md",
              ],
  ],
  Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true"
  )
)

deploydocs(
           repo = "github.com/charleskawczynski/BetweenFlags.jl.git",
          )
