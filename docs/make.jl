# Base.HOME_PROJECT[] = abspath(Base.HOME_PROJECT[]) # JuliaLang/julia/pull/28625

push!(LOAD_PATH, "../")
using Documenter
using BetweenFlags

makedocs(
  sitename = "BetweenFlags.jl",
  doctest = false,
  strict = false,
  format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    # prettyurls = !("local" in ARGS),
    canonical = "https://charleskawczynski.github.io/BetweenFlags.jl/stable/",
  ),
  clean = false,
  modules = [Documenter, BetweenFlags],
  pages = Any[
  "Home" => "index.md",
  "Functions" => Any[
               "Functions/Greedy.md",
               "Functions/LevelBased.md",
              ],
  ],
)

deploydocs(
           repo = "github.com/charleskawczynski/BetweenFlags.jl.git",
           target = "build",
          )
