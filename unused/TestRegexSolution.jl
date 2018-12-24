using Test
using BetweenFlags

function main()
  path_separator = Sys.iswindows() ? "\\" : "/"
  println("Testing ",split(@__FILE__, path_separator)[end],"...")

  test_regex()
end

function test_regex()
  s = "Some text... {GRAB THIS}, some more text {GRAB THIS TOO}..."

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
  s_i = string(s_i, "\n", "    more stuff")
  s_i = string(s_i, "\n", "  end")
  s_i = string(s_i, "\n", "end")
  s_i = string(s_i, "\n", "more text")

  reg = r"\bif\b(.|\n)*\bend\b"
  m = match(reg, s_i)

  print("\n")
  if m==nothing
    print("\nno match\n")
  else
    # print(m)
    print("\n-------------------match: \n")
    print(m.match)
    print("\n-------------------\n")
    print("\n, m.captures = ",m.captures)
    print("\n, m.offset   = ",m.offset)
    print("\n, m.offsets  = ",m.offsets)
  end
  print("\n")
  @test true
end


if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
