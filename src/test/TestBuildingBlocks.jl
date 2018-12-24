using Test
using PerFlagFuncs

function main()
  path_separator = Sys.iswindows() ? "\\" : "/"
  println("Testing ",split(@__FILE__, path_separator)[end],"...")

  test_merge_odd_even()
  test_get_alternating_consecutive_vector()
end

function test_merge_odd_even()
  a = [1, 3, 5]
  b = [2, 4, 6]
  c = PerFlagFuncs.merge_even_odd(a, b)
  @testset begin
      @test all([x==y for (x, y) in zip(c, [1, 2, 3, 4, 5, 6])])
  end
end

function test_get_alternating_consecutive_vector()
  # This function is a bit difficult to test. Instead
  # of writing tests, the inputs and outputs are
  # be printed to manually ensure that the outputs
  # are what we expect.
  print_IO = false
  N_A = Base.rand(10:50)[1]
  N_B = Base.rand(10:50)[1]
  if print_IO
    print("\n ********************************************************** test_get_alternating_consecutive_vector \n")
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
  (C, D) = PerFlagFuncs.get_alternating_consecutive_vector(A, B)
  if print_IO
    print("C = ", C,"\n")
    print("D = ", D,"\n")
    print("\n------------------------- Merged\n")
  end
  M = PerFlagFuncs.merge_even_odd(C, D)
  if print_IO
    print(M, "\n")
    print("\n ********************************************************** \n")
  end
end


if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
