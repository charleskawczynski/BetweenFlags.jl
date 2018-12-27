using Test
include(joinpath(pwd(), "Includes.jl"))

using FeaturedFuncs

function main()
  path_separator = Sys.iswindows() ? "\\" : "/"
  println("Testing ",split(@__FILE__, path_separator)[end],"...")

  test_get_between_flags_flat()
  test_get_between_flags_level_flat()
  test_get_between_flags_level_flat_practical()

  test_get_between_flags_level_practical_complex()

  test_remove_between_flags()
end

function test_get_between_flags_flat()
  s_i1 = "Some text... {GRAB THIS}, some more text {GRAB THIS TOO}..."
  L_o1 = FeaturedFuncs.get_between_flags_flat(s_i1, ["{"], ["}"])
  s_i2 = "Some text... {GRAB THIS}, some more text {GRAB THIS TOO}..."
  L_o2 = FeaturedFuncs.get_between_flags_flat(s_i2, ["{"], ["}"], false)
  s_i3 = "Some text... {GRAB THIS), } some more text {GRAB THIS TOO}..."
  L_o3 = FeaturedFuncs.get_between_flags_flat(s_i3, ["{"], ["}", ")"])
  s_i4 = "Some text... {GRAB THIS), } some more text {GRAB THIS TOO}..."
  L_o4 = FeaturedFuncs.get_between_flags_flat(s_i4, ["{"], ["}", ")"], false)

  @testset begin
      @test L_o1[1]=="{GRAB THIS}"
      @test L_o2[1]=="GRAB THIS"
      @test L_o3[1]=="{GRAB THIS)"
      @test L_o4[1]=="GRAB THIS"
      @test L_o1[2]=="{GRAB THIS TOO}"
      @test L_o2[2]=="GRAB THIS TOO"
      @test L_o3[2]=="{GRAB THIS TOO}"
      @test L_o4[2]=="GRAB THIS TOO"
  end
end

function test_get_between_flags_level_flat()
  s_i1 = "Some text... {GRAB {THIS}}, some more text {GRAB THIS TOO}..."
  L_o1 = FeaturedFuncs.get_between_flags_level_flat(s_i1, ["{"], ["}"])
  s_i2 = "Some text... {GRAB {THIS}}, some more text {GRAB THIS TOO}..."
  L_o2 = FeaturedFuncs.get_between_flags_level_flat(s_i2, ["{"], ["}"], false)
  s_i3 = "Some text... {GRAB {THIS}), } some more text {GRAB THIS TOO}..."
  L_o3 = FeaturedFuncs.get_between_flags_level_flat(s_i3, ["{"], ["}", ")"])
  s_i4 = "Some text... {GRAB {THIS}), } some more text {GRAB THIS TOO}..."
  L_o4 = FeaturedFuncs.get_between_flags_level_flat(s_i4, ["{"], ["}", ")"], false)

  @testset begin
      @test L_o1[1]=="{GRAB {THIS}}"
      @test L_o2[1]=="GRAB {THIS}"
      @test L_o3[1]=="{GRAB {THIS})"
      @test L_o4[1]=="GRAB {THIS}"
      @test L_o1[2]=="{GRAB THIS TOO}"
      @test L_o2[2]=="GRAB THIS TOO"
      @test L_o3[2]=="{GRAB THIS TOO}"
      @test L_o4[2]=="GRAB THIS TOO"
  end
end

function test_get_between_flags_level_flat_practical()
  s_i = ""
  s_i = string(s_i, "\n", "Some text")
  s_i = string(s_i, "\n", "function myfunc()")
  s_i = string(s_i, "\n", "  more stuff")
  s_i = string(s_i, "\n", "  if something")
  s_i = string(s_i, "\n", "    print('something')")
  s_i = string(s_i, "\n", "  else")
  s_i = string(s_i, "\n", "    print('not something')")
  s_i = string(s_i, "\n", "  end")
  s_i = string(s_i, "\n", "  more stuff")
  s_i = string(s_i, "\n", "end")
  s_i = string(s_i, "\n", "more text")
  L_o = FeaturedFuncs.get_between_flags_level_flat(s_i, ["function ", "if "], [" end", "\nend"])

  s_o = ""
  s_o = string(s_o,       "function myfunc()")
  s_o = string(s_o, "\n", "  more stuff")
  s_o = string(s_o, "\n", "  if something")
  s_o = string(s_o, "\n", "    print('something')")
  s_o = string(s_o, "\n", "  else")
  s_o = string(s_o, "\n", "    print('not something')")
  s_o = string(s_o, "\n", "  end")
  s_o = string(s_o, "\n", "  more stuff")
  s_o = string(s_o, "\n", "end")

  @testset begin
      @test L_o[1]==s_o
  end
end

function test_get_between_flags_level_practical_complex()
  s_i = ""
  s_i = string(s_i, "\n", "Some text")
  s_i = string(s_i, "\n", "if something")
  s_i = string(s_i, "\n", "  function myfunc()")
  s_i = string(s_i, "\n", "    more stuff")
  s_i = string(s_i, "\n", "    if something")
  s_i = string(s_i, "\n", "      print('something')")
  s_i = string(s_i, "\n", "    else")
  s_i = string(s_i, "\n", "      print('not something')")
  s_i = string(s_i, "\n", "    end")
  s_i = string(s_i, "\n", "    for something")
  s_i = string(s_i, "\n", "      print('something')")
  s_i = string(s_i, "\n", "    else")
  s_i = string(s_i, "\n", "      print('not something')")
  s_i = string(s_i, "\n", "    end")
  s_i = string(s_i, "\n", "    more stuff")
  s_i = string(s_i, "\n", "  end")
  s_i = string(s_i, "\n", "end")
  s_i = string(s_i, "\n", "more text")

  word_boundaries_left = ["\n", " ", ";"]
  word_boundaries_right = ["\n", " ", ";"]
  word_boundaries_right_if = [" ", ";"]

  FS_outer = FlagSet(
    Flag("function", word_boundaries_left, word_boundaries_right),
    Flag("end",      word_boundaries_left, word_boundaries_right)
  )

  FS_inner = [
  FlagSet(
    Flag("if",       word_boundaries_left, word_boundaries_right_if),
    Flag("end",      word_boundaries_left, word_boundaries_right)
  ),
  FlagSet(
    Flag("for",      word_boundaries_left, word_boundaries_right),
    Flag("end",      word_boundaries_left, word_boundaries_right)
  )]

  L_o = FeaturedFuncs.get_between_flags_level(s_i, FS_outer, FS_inner)

  s_o = ""
  s_o = string(s_o,       " function myfunc()") # The extra space is due to the left word boundary of the function...
  s_o = string(s_o, "\n", "    more stuff")
  s_o = string(s_o, "\n", "    if something")
  s_o = string(s_o, "\n", "      print('something')")
  s_o = string(s_o, "\n", "    else")
  s_o = string(s_o, "\n", "      print('not something')")
  s_o = string(s_o, "\n", "    end")
  s_o = string(s_o, "\n", "    for something")
  s_o = string(s_o, "\n", "      print('something')")
  s_o = string(s_o, "\n", "    else")
  s_o = string(s_o, "\n", "      print('not something')")
  s_o = string(s_o, "\n", "    end")
  s_o = string(s_o, "\n", "    more stuff")
  s_o = string(s_o, "\n", "  end\n") # The \n is due to the right word boundary of the "end"

  @testset begin
      @test L_o[1]==s_o
  end
end

function test_remove_between_flags()
  s_i1 = "Here is some text, and {THIS SHOULD BE REMOVED}, FeaturedFuncs offers a simple interface..."
  s_o1 = FeaturedFuncs.remove_between_flags_flat(s_i1, ["{"], ["}"])
  s_i2 = "Here is some text, and {THIS SHOULD BE REMOVED}, FeaturedFuncs offers a simple interface..."
  s_o2 = FeaturedFuncs.remove_between_flags_flat(s_i2, ["{"], ["}"], false)
  s_i3 = "Here is some text, and {THIS SHOULD BE REMOVED), FeaturedFuncs} offers a simple interface..."
  s_o3 = FeaturedFuncs.remove_between_flags_flat(s_i3, ["{"], ["}", ")"])
  s_i4 = "Here is some text, and {THIS SHOULD BE REMOVED), FeaturedFuncs} offers a simple interface..."
  s_o4 = FeaturedFuncs.remove_between_flags_flat(s_i3, ["{"], ["}", ")"], false)

  @testset begin
      @test s_o1=="Here is some text, and , FeaturedFuncs offers a simple interface..."
      @test s_o2=="Here is some text, and {}, FeaturedFuncs offers a simple interface..."
      @test s_o3=="Here is some text, and , FeaturedFuncs} offers a simple interface..."
      @test s_o4=="Here is some text, and {), FeaturedFuncs} offers a simple interface..."
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
