using Test
using BetweenFlags

@testset "Flag pair" begin
    flag1 = StartFlag("flag1")
    flag2 = StopFlag("flag2")
    flag_set = FlagPair{GreedyType}(
        flag1,
        flag2,
    )
    @test flag_set.start == flag1
    @test flag_set.stop  == flag2
    @test flag_set.ID == "flag1-flag2"
end
