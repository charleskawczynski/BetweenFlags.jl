using Test
using BetweenFlags
import BetweenFlags

@testset "Greedy - length(flag)>length(word bc)" begin
  flag_set = FlagSet([
      FlagPair{GreedyType}(
          StartFlag("{", ["*"], [""]),
          StopFlag( "}", [""], ["*"])
      )
  ])

  text = "Foo, bar..."
  token_stream = TokenStream(text, flag_set)
  @test token_stream("{-}") == ""

  text = "Foo,*{}*, bar..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("{-}") == "{}"

  text = "Foo,*{a}{b}*, bar..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("{-}") == "{a}{b}"

  text = "Foo, *{a} {b}*, bar..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  # Consecutive scopes are concatenated (in `get_string`):
  @test token_stream("{-}") == "{a} {b}"

  text = "Foo, *{bar}*, foobar..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("{-}") == "{bar}"

  text = "Foo, *{{foobar}*}, foobaz..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("{-}") == "{{foobar}"
end

@testset "Scope - flag subsets" begin
  flag_set = FlagSet([
      FlagPair{ScopeType}(
          StartFlag("do", ["*"], [""]),
          StopFlag( "end do", [""], ["*"])
      )
  ])
  text = "Foo, *do bar; foo end do*, foobar..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("do-end do") == "do bar; foo end do"
end

@testset "Scope - nested" begin
  flag_set = FlagSet([
      FlagPair{ScopeType}(
          StartFlag("{", ["*"], [""]),
          StopFlag( "}", [""], ["*"])
      )
  ])

  text = "Foo, *{bar}*, foobar..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("{-}") == "{bar}"

  text = "Foo, *{{bar}}*, foobar..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("{-}") == "{{bar}}"

  text = "Foo, *{{bar}{baz}}*, foobar..."
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("{-}") == "{{bar}{baz}}"

end

@testset "Greedy - length(flag)==length(word bc)" begin
  flag_set = FlagSet([
      FlagPair{GreedyType}(
          StartFlag("ABC_ABC_L", ["STA_WBC_L"], ["STA_WBC_R"]),
          StopFlag( "ABC_ABC_R", ["STO_WBC_L"], ["STO_WBC_R"])
      )
  ])

  text = "foo STA_WBC_LABC_ABC_LSTA_WBC_R bar STO_WBC_LABC_ABC_RSTO_WBC_R foobar"
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("ABC_ABC_L-ABC_ABC_R") == "ABC_ABC_LSTA_WBC_R bar STO_WBC_LABC_ABC_R"

end

@testset "Greedy - length(flag)<length(word bc)" begin
  flag_set = FlagSet([
      FlagPair{GreedyType}(
          StartFlag("ABC_L", ["XYZ_XYZ_STA_WBC_L"], ["XYZ_XYZ_STA_WBC_R"]),
          StopFlag( "ABC_R", ["XYZ_XYZ_STO_WBC_L"], ["XYZ_XYZ_STO_WBC_R"])
      )
  ])

  text = "foo XYZ_XYZ_STA_WBC_LABC_LXYZ_XYZ_STA_WBC_R bar XYZ_XYZ_STO_WBC_LABC_RXYZ_XYZ_STO_WBC_R foobar"
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("ABC_L-ABC_R") == "ABC_LXYZ_XYZ_STA_WBC_R bar XYZ_XYZ_STO_WBC_LABC_R"

end

@testset "start_flag == stop_flag, same word bcs" begin
  flag_set = FlagSet([
        FlagPair{GreedyType}(
        StartFlag("|", ["*"], [" "]),
        StopFlag( "|", [" "], ["*"])
        )
        ])
  text = "baz*| foo |*baz*| bar |*foobaz"
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("|-|") == "| foo || bar |"
end

@testset "Unicode" begin
  flag_set = FlagSet([
        FlagPair{GreedyType}(
        StartFlag("|", ["*"], [" "]),
        StopFlag( "|", [" "], ["*"])
        )
        ])
  text = "baz*| θ |*baz*| ϕ |*foobaz"
  token_stream = TokenStream(text, flag_set; rm_outer_bcs=true)
  @test token_stream("|-|") == "| θ || ϕ |"
end
