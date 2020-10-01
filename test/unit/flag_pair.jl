using Test
using BetweenFlags

@testset "Flag pair" begin
    flag1 = Flag("flag1"; flag_type=StartType())
    flag2 = Flag("flag2")
    flag_set = FlagPair(
        flag1,
        flag2,
    )
    @test flag_set.start == flag1
    @test flag_set.stop  == flag2
    @test flag_set.ID == "flag1-flag2"
end
