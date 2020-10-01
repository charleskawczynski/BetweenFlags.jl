using Documenter, BetweenFlags

makedocs(
  sitename = "BetweenFlags.jl",
  doctest = false,
  strict = true,
  format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    canonical = "https://charleskawczynski.github.io/BetweenFlags.jl/stable/",
  ),
  clean = true,
  modules = [BetweenFlags],
  pages = Any[
  "Home" => "index.md",
  "API" => "api.md",
  ],
)

deploydocs(
           repo = "github.com/charleskawczynski/BetweenFlags.jl.git",
           target = "build",
           push_preview = true,
          )
