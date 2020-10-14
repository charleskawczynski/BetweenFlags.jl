using Test
using BetweenFlags

code_dir = joinpath(dat_dir, "julia", "simple_func")

"""
    post_process

Remove end of line ("\r\n") (Windows)
Remove carriage return ("\r") Mac OS (before X)
"""
function post_process(s)
  s = replace(s, "\r\n" => "\n")
  s = replace(s, "\r" => "\n")
  return s
end

@testset "julia/simple_func" begin

  filename = joinpath(code_dir, "input.jl")
  code = open(f->read(f, String), filename)

  flag_set = FlagSet([
  FlagPair{ScopeType}(
    StartFlag("function", ["\n",""], [" "]),
    StopFlag( "end",      ["\n","\r"], ["\n","\r"];)
  ),
  FlagPair{ScopeType}(
    StartFlag("if",       ["\n"], [" "]),
    StopFlag( "end",      ["\n","\r"], ["\n","\r"])
  ),
  FlagPair{ScopeType}(
    StartFlag("for",      ["\n"], [" "]),
    StopFlag( "end",      ["\n","\r"], ["\n","\r"])
  )])

  token_stream = TokenStream(code, flag_set)
  export_results && export_plot(token_stream,code; path=code_dir)

  ####
  #### for-end
  ####
  section = token_stream("for-end")
  section_expected = open(f->read(f, String), joinpath(code_dir, "expected_for.jl"))

  # TODO: account for return carriage
  @test post_process(section)==post_process(section_expected)

  # To remove:
  # filename = joinpath(code_dir, "output_for.jl")
  # open(filename,"w") do io
  #   print(io, section)
  # end

  ####
  #### if-end
  ####
  section = token_stream("if-end")
  section_expected = open(f->read(f, String), joinpath(code_dir, "expected_if.jl"))
  # # TODO: account for return carriage
  @test post_process(section)==post_process(section_expected)

  # To remove:
  # filename = joinpath(code_dir, "output_if.jl")
  # open(filename,"w") do io
  #   print(io, section)
  # end


end

@testset "Julia: if/function code block" begin

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
  FlagPair{ScopeType}(
    StartFlag("function", ["\n"," "], [" "]),
    StopFlag( "end",      ["\n","\r"], ["\n","\r"])
  ),
  FlagPair{ScopeType}(
    StartFlag("if",       ["\n", " "], [" "]),
    StopFlag( "end",      ["\n","\r", " "], ["\n","\r"])
  ),
  FlagPair{ScopeType}(
    StartFlag("for",      ["\n", " "], [" "]),
    StopFlag( "end",      ["\n","\r", " "], ["\n","\r"])
  )])

  token_stream = TokenStream(text, flag_set)

  @test token_stream("if-end") == text_expected
  export_results && export_plot(token_stream, text; path=".")

end
