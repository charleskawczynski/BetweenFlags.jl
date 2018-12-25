using Documenter
using BetweenFlags

makedocs(
    sitename = "BetweenFlags",
    format = :html,
    modules = [BetweenFlags]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
