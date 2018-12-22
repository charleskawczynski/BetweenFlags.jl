using Test
using BetweenFlags

function main()

  test_merge_odd_even()
  test_get_alternating_consecutive_list()
  test_get_between_flags()
  test_remove_between_flags()
end

function test_merge_odd_even()
  a = [1, 3, 5]
  b = [2, 4, 6]
  c = BetweenFlags.merge_even_odd(a, b)
  @testset begin
      @test all([x==y for (x, y) in zip(c, [1, 2, 3, 4, 5, 6])])
  end
end

function test_get_alternating_consecutive_list()
  # This function is a bit difficult to test. Instead
  # of writing tests, the inputs and outputs are
  # be printed to manually ensure that the outputs
  # are what we expect.
  print_IO = false
  N_A = Base.rand(10:50)[1]
  N_B = Base.rand(10:50)[1]
  if print_IO
    print("\n ********************************************************** test_get_alternating_consecutive_list \n")
    print("N_A = ", N_A,"\n")
    print("N_B = ", N_B,"\n")
  end
  A = unique([Base.rand(1:20)[1] for x in 1:Base.rand(1:N_A)])
  B = unique([Base.rand(1:20)[1] for x in 1:Base.rand(1:N_B)])
  if print_IO
    print("A = ", A,"\n")
    print("B = ", B,"\n")
  end
  dupes = [x for x in A for y in B if x==y]
  if print_IO
    print("dupes = ", dupes,"\n")
  end
  A = [x for x in A if !any([x == y for y in dupes])]
  B = [x for x in B if !any([x == y for y in dupes])]
  if print_IO
    print("A = ", A,"\n")
    print("B = ", B,"\n")
  end
  sort!(A)
  sort!(B)
  if print_IO
    print("\n------------------------- Original\n")
    print("A = ", A,"\n")
    print("B = ", B,"\n")
    print("\n------------------------- Modified\n")
  end
  (C, D) = BetweenFlags.get_alternating_consecutive_list(A, B)
  if print_IO
    print("C = ", C,"\n")
    print("D = ", D,"\n")
    print("\n------------------------- Merged\n")
  end
  M = BetweenFlags.merge_even_odd(C, D)
  if print_IO
    print(M, "\n")
    print("\n ********************************************************** \n")
  end
end

function test_get_between_flags()
  s_i1 = "Here is some text, and {THIS SHOULD BE GRABBED}, BetweenFlags offers a simple interface..."
  s_o1 = BetweenFlags.get(s_i1, ["{"], ["}"])
  s_i2 = "Here is some text, and {THIS SHOULD BE GRABBED}, BetweenFlags offers a simple interface..."
  s_o2 = BetweenFlags.get(s_i2, ["{"], ["}"], false)
  s_i3 = "Here is some text, and {THIS SHOULD BE GRABBED), BetweenFlags} offers a simple interface..."
  s_o3 = BetweenFlags.get(s_i3, ["{"], ["}", ")"])
  s_i4 = "Here is some text, and {THIS SHOULD BE GRABBED), BetweenFlags} offers a simple interface..."
  s_o4 = BetweenFlags.get(s_i3, ["{"], ["}", ")"], false)

  @testset begin
      @test s_o1=="{THIS SHOULD BE GRABBED}"
      @test s_o2=="THIS SHOULD BE GRABBED"
      @test s_o3=="{THIS SHOULD BE GRABBED)"
      @test s_o4=="THIS SHOULD BE GRABBED"
  end
end

function test_remove_between_flags()
  s_i1 = "Here is some text, and {THIS SHOULD BE REMOVED}, BetweenFlags offers a simple interface..."
  s_o1 = BetweenFlags.remove(s_i1, ["{"], ["}"])
  s_i2 = "Here is some text, and {THIS SHOULD BE REMOVED}, BetweenFlags offers a simple interface..."
  s_o2 = BetweenFlags.remove(s_i2, ["{"], ["}"], false)
  s_i3 = "Here is some text, and {THIS SHOULD BE REMOVED), BetweenFlags} offers a simple interface..."
  s_o3 = BetweenFlags.remove(s_i3, ["{"], ["}", ")"])
  s_i4 = "Here is some text, and {THIS SHOULD BE REMOVED), BetweenFlags} offers a simple interface..."
  s_o4 = BetweenFlags.remove(s_i3, ["{"], ["}", ")"], false)

  @testset begin
      @test s_o1=="Here is some text, and , BetweenFlags offers a simple interface..."
      @test s_o2=="Here is some text, and {}, BetweenFlags offers a simple interface..."
      @test s_o3=="Here is some text, and , BetweenFlags} offers a simple interface..."
      @test s_o4=="Here is some text, and {), BetweenFlags} offers a simple interface..."
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
