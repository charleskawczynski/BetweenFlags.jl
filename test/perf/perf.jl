using Test
using BetweenFlags

@testset "Scaling" begin
  flag_set = FlagSet([
        FlagPair{GreedyType}(
        StartFlag("|", [" "], [" "]),
        StopFlag( "|", [" "], [" "])
        )
        ])
  base_text = "baz | foo | baz | bar | foobaz "
  timings = Dict()
  for n in 10 .^ (1:3)
    text = repeat(base_text,n)
    Δt = @elapsed TokenStream(text, flag_set)
    @show n, Δt
  end
end

# using Profile
# @testset "Profile" begin
#   flag_set = FlagSet([
#         FlagPair{GreedyType}(
#         StartFlag("|", [" "], [" "]),
#         StopFlag( "|", [" "], [" "])
#         )
#         ])
#   base_text = "baz | foo | baz | bar | foobaz "
#   base_text = "foo | θ | bar | ψ | foobar "

#   text = repeat(base_text,1)
#   ts = TokenStream(text, flag_set)

#   text = repeat(base_text,10^3)
#   ts = @profile TokenStream(text, flag_set)
#   Profile.print()
# end
