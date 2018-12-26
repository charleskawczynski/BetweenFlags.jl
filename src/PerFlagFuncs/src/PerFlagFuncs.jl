module PerFlagFuncs
# using Plots

export count_flags
export find_next_iter
export merge_even_odd
export get_alternating_consecutive_vector

function count_flags(s::String, needle::String)
  cnt = 0
  LN = length(needle)
  LS = length(s)
  if LN <= LS
    for i in 1:LS-LN+1
      substr = s[i:i+LN-1]
      if needle==substr
        cnt += 1
      end
    end
  end
  return cnt
end

function find_next_iter(s::String, pattern::String)
  ind = []
  LN = length(pattern)
  LS = length(s)
  if LN <= LS
    for i in 1:LS-LN+1
      substr = s[i:i+LN-1]
      if pattern==substr
        push!(ind, i)
      end
    end
  end
  return ind
end

function merge_even_odd(odd::Vector{Int64}, even::Vector{Int64})
  return [odd even]'[:]
end

function get_alternating_consecutive_vector(A::Vector{Int64}, B::Vector{Int64}, level=nothing, level_outer=nothing, s=nothing)
  DEBUG = false
  N_AB = max(A..., B...)
  s_given = !(s == nothing)
  level_given = !(level == nothing)
  level_outer_given = !(level_outer == nothing)

  if s_given
    DEBUG = true
    N_s = length(s)
    N_AB = N_s
  else
    N_s = N_AB
    s = repeat('*', N_s)
  end
  if !level_given
    level = zeros(N_s)
  end
  if !level_outer_given
    level_outer = zeros(N_s)
  end
  # if level_outer_given && level_given
  #   print("\n")
  #   print("\nN_s                 = ", N_s)
  #   print("\nlength(level)       = ", length(level))
  #   print("\nlength(level_outer) = ", length(level_outer))
  #   print("\n")
  #   plot([Float64(x) for x in 1:N_s][23:27], level[23:27])
  #   plot!(title = "level", xlabel = "character", ylabel = "level")
  #   png("level")
  #   plot([Float64(x) for x in 1:N_s][23:27], level_outer[23:27])
  #   plot!(title = "level_outer", xlabel = "character", ylabel = "level_outer")
  #   png("level_outer")
  # end

  L = Vector{Int64}(undef, 0)
  e = Vector{Int64}(undef, 0)
  (C, D) = Tuple([e, e])
  B_available = B
  if DEBUG
    print("\n ************************************************* Debugging get_alternating_consecutive_vector \n")
  end
  if length(A) > 0 && length(B) > 0
    b_previous = B[1]
    j_previous = 1
    for (i, a) in enumerate(A)
      a_minus_one = max(a-1, 1)
      found = false
      for (j, b) in enumerate(B_available)
        b_plus_one = min(b+1, N_s)
        cond_outer_start = level_outer[a_minus_one]+1==level_outer[a]
        # cond_outer_stop  = level_outer[b_plus_one]+1==level_outer[b]
        # cond_outer_start = true
        # cond_outer_stop  = true
        if s_given
          cond_outer = cond_outer_start && cond_outer_stop || (i==1 || j==1)
        else
          cond_outer = true
        end
        cond = ( b > a && a > b_previous ) || ( b > a && a == A[1] ) && !found && level[a]==level[b] && cond_outer
        if DEBUG
          print("\n")
          print("a=", a)
          print(",b=", b)
          print(",s[",a, ",", b,"]=", s[a], s[b])
          print(",level[",a,",",b,"]=", level[a], level[b])
          print(",level_outer[",a,",",b,"]=", level_outer[a], level_outer[b])
          print(",cond=", cond)
        end
        if cond
          push!(L, a)
          push!(L, b)
          B_available = [x for x in B_available if x > b_previous]
          b_previous = b
          j_previous = j
          found = true
        end
      end
    end
    C = L[1:2:end]
    D = L[2:2:end]
  end
  if DEBUG
    print("\n ************************************************* \n")
  end
  return Tuple([C, D])
end

end