module PerFlagFuncs

export count_flags
export find_next_iter
export merge_even_odd
export get_alternating_consecutive_vector

"""

count_flags(s::String, needle::String)

Counts number of flags in a given string.

"""
function count_flags(s::String, flags::String)
  cnt = 0
  LN = length(flags)
  LS = length(s)
  if LN <= LS
    for i in 1:LS-LN+1
      substr = s[i:i+LN-1]
      if flags==substr
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

function get_alternating_consecutive_vector(A::Vector{Int64}, B::Vector{Int64}, level=nothing, level_outer=nothing)
  if level == nothing
    level = zero(1:max(A..., B...))
  end
  if level_outer == nothing
    level_outer = zero(1:max(A..., B...))
  end
  L = Vector{Int64}(undef, 0)
  e = Vector{Int64}(undef, 0)
  (C, D) = Tuple([e, e])
  B_available = B
  if length(A) > 0 && length(B) > 0
    b_previous = B[1]
    j_previous = 1
    for (i, a) in enumerate(A)
      found = false
      for (j, b) in enumerate(B_available)
        cond = ( b > a && a > b_previous ) || ( b > a && a == A[1] ) && !found && level[a]==level[b]
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
  return Tuple([C, D])
end

end