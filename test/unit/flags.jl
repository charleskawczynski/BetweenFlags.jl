using Test
using BetweenFlags

@testset "Flags" begin
    for Flag in (StartFlag, StopFlag)
        flag = Flag("flag")
        @test flag.flag == "flag"
        @test flag.flag_boundaries_left == []
        @test flag.flag_boundaries_right == []
        @test flag.trigger == ["flag"]
        @test BetweenFlags.grep_type(flag) == GreedyType

        flag = Flag("flag",
                    ["LB1","LB2"],
                    ["RB1","RB2"];
                    grep_type=ScopeType())
        @test flag.flag == "flag"
        @test flag.flag_boundaries_left == ["LB1","LB2"]
        @test flag.flag_boundaries_right == ["RB1","RB2"]
        @test flag.trigger ==  ["LB1flagRB1", "LB1flagRB2", "LB2flagRB1", "LB2flagRB2"]
        @test BetweenFlags.grep_type(flag) == ScopeType

        flag = Flag("flag",
                    ["LB1","LB2"],
                    ["RB1","RB2"];
                    grep_type=ScopeType())
        @test flag.flag == "flag"
        @test flag.flag_boundaries_left == ["LB1","LB2"]
        @test flag.flag_boundaries_right == ["RB1","RB2"]
        @test flag.trigger ==  ["LB1flagRB1", "LB1flagRB2", "LB2flagRB1", "LB2flagRB2"]
        @test BetweenFlags.grep_type(flag) == ScopeType
    end
end
