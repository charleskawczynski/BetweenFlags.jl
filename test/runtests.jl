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
  @testset "Unit tests" begin
    @testset "Flags" begin
      include(joinpath("unit","flags.jl"))
      include(joinpath("unit","flag_pair.jl"))
    end
    @testset "Tokenize - with boundaries" begin
      include(joinpath("unit","tokenize.jl"))
    end
    @testset "Tokenize - no outer boundaries" begin
      include(joinpath("unit","tokenize_no_outer_boundaries.jl"))
    end
  end
  @testset "Data-driven tests" begin
    include(joinpath("data_driven","tokenize.jl"))
  end
  @testset "Performance tests" begin
    include(joinpath("perf","perf.jl"))
  end
end

