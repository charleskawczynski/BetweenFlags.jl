using Test
using BetweenFlags
import BetweenFlags
const BF = BetweenFlags

@testset "Greedy - length(flag)>length(word bc)" begin
  flag_set = FlagSet([
      FlagPair(
          Flag("{", [""], [""];flag_type= StartType()),
          Flag("}", [""], [""])
      )
  ])

  text = "Foo, bar..."
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "{-}") == ""

  text = "Foo, {}, bar..."
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "{-}") == "{}"

  text = "Foo, {a}{b}, bar..."
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "{-}") == "{a}{b}"

  text = "Foo, {a} {b}, bar..."
  token_stream = BF.tokenize(text, flag_set)
  # Consecutive scopes are concatenated (in `get_string`):
  @test BF.get_string(text, token_stream, "{-}") == "{a}{b}"

  text = "Foo, {bar}, foobar..."
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "{-}") == "{bar}"

  text = "Foo, {{bar}}, foobar..."
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "{-}") == "{{bar}"
end

@testset "Scope - nested" begin
  flag_set = FlagSet([
      FlagPair(
          Flag("{", [""], [""];flag_type= StartType()),
          Flag("}", [""], [""];flag_type= StopType())
      )
  ])

  text = "Foo, {bar}, foobar..."
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "{-}") == "{bar}"

  text = "Foo, {{bar}}, foobar..."
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "{-}") == "{{bar}}"

  text = "Foo, {{bar}{baz}}, foobar..."
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "{-}") == "{{bar}{baz}}"

end

@testset "Greedy - length(flag)==length(word bc)" begin
  flag_set = FlagSet([
      FlagPair(
          Flag("ABC_ABC_L", ["STA_WBC_L"], ["STA_WBC_R"];flag_type= StartType()),
          Flag("ABC_ABC_R", ["STO_WBC_L"], ["STO_WBC_R"])
      )
  ])

  text = "foo STA_WBC_LABC_ABC_LSTA_WBC_R bar STO_WBC_LABC_ABC_RSTO_WBC_R foobar"
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "ABC_ABC_L-ABC_ABC_R") == "STA_WBC_LABC_ABC_LSTA_WBC_R bar STO_WBC_LABC_ABC_RSTO_WBC_R"

end

@testset "Greedy - length(flag)<length(word bc)" begin
  flag_set = FlagSet([
      FlagPair(
          Flag("ABC_L", ["XYZ_XYZ_STA_WBC_L"], ["XYZ_XYZ_STA_WBC_R"];flag_type= StartType()),
          Flag("ABC_R", ["XYZ_XYZ_STO_WBC_L"], ["XYZ_XYZ_STO_WBC_R"])
      )
  ])

  text = "foo XYZ_XYZ_STA_WBC_LABC_LXYZ_XYZ_STA_WBC_R bar XYZ_XYZ_STO_WBC_LABC_RXYZ_XYZ_STO_WBC_R foobar"
  token_stream = BF.tokenize(text, flag_set)
  @test BF.get_string(text, token_stream, "ABC_L-ABC_R") == "XYZ_XYZ_STA_WBC_LABC_LXYZ_XYZ_STA_WBC_R bar XYZ_XYZ_STO_WBC_LABC_RXYZ_XYZ_STO_WBC_R"

end

@testset "Scope - longer example" begin

  text = "Foo
if cond
    function myfunc()
        more stuff
        if cond
            print('foobar')
        else
            print('foobar')
        end
        for cond2
            print('foobar')
        else
            print('foobar')
        end
        foobaz
    end
end
baz"

  text_expected = "
if cond
    function myfunc()
        more stuff
        if cond
            print('foobar')
        else
            print('foobar')
        end
        for cond2
            print('foobar')
        else
            print('foobar')
        end
        foobaz
    end
end
"
  flag_set = FlagSet([
  FlagPair(
    Flag("function", ["\n"," "], [" "];flag_type= StartType()),
    Flag("end",      ["\n","\r"], ["\n","\r"];flag_type= StopType())
  ),
  FlagPair(
    Flag("if",       ["\n", " "], [" "];flag_type= StartType()),
    Flag("end",      ["\n","\r", " "], ["\n","\r"];flag_type= StopType())
  ),
  FlagPair(
    Flag("for",      ["\n", " "], [" "];flag_type= StartType()),
    Flag("end",      ["\n","\r", " "], ["\n","\r"];flag_type= StopType())
  )])

  token_stream = BF.tokenize(text, flag_set)

  @test BF.get_string(text, token_stream, "if-end") == text_expected
  export_results && export_plot(token_stream, text; path=".")

end
