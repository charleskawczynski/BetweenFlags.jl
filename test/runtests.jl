using BetweenFlags
using Test
const src_dir = dirname(dirname(pathof(BetweenFlags)))
const out_dir = joinpath(src_dir, "output")
const fig_dir = joinpath(out_dir, "figs")
const dat_dir = joinpath(src_dir, "data")

export_results = false
if export_results
    include("plot_helper.jl")
end

@testset "BetweenFlags" begin
    include(joinpath("unit","flags.jl"))
    include(joinpath("unit","flag_pair.jl"))
    include(joinpath("unit","tokenize.jl"))
    include(joinpath("data_driven","tokenize.jl"))
    include(joinpath("perf","perf.jl"))
end

