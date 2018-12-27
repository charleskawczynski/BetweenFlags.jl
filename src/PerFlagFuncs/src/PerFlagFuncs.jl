module PerFlagFuncs
# using Plots

export split_by_consecutives
export count_flags
export find_next_iter
export merge_even_odd
export get_alternating_consecutive_vector

function split_by_consecutives(A::Vector{Int})
  N = length(A)
  if N>1
    sig = vcat(diff(A), [1])
    N_groups = count(map(x->x==1, sig))+1
    A_sub = Vector{Int}()
    A_split = Vector{Vector{Int}}([])
    k=1
    for (a, s) in zip(A, sig)
      push!(A_sub, a)
      if !(s==1)
        push!(A_split, A_sub)
        A_sub = Vector{Int}([])
        k+=1
      end
      if a==A[N] && !(s==1)==false
        push!(A_split, A_sub)
      end
    end
    return A_split
  else
    return [A]
  end
end

function count_flags(s::String, flag::String)
  cnt = 0
  LN = length(flag)
  LS = length(s)
  if LN <= LS
    for i in 1:LS-LN+1
      substr = s[i:i+LN-1]
      if flag==substr
        cnt += 1
      end
    end
  end
  return cnt
end

function find_next_iter(s::String, flag::String)
  ind = []
  LN = length(flag)
  LS = length(s)
  if LN <= LS
    for i in 1:LS-LN+1
      substr = s[i:i+LN-1]
      if flag==substr
        push!(ind, i)
      end
    end
  end
  return ind
end

function merge_even_odd(odd::Vector{Int64}, even::Vector{Int64})
  return [odd even]'[:]
end

function get_region(v, i)
  return string(v[i-1],",",v[i],",",v[i+1])
end

function get_alternating_consecutive_vector(A::Vector{Int64}, B::Vector{Int64}, level_total=nothing, level_outer=nothing, s=nothing)
  DEBUG = false
  N_AB = max(A..., B...)
  s_given = !(s == nothing)
  level_given = !(level_total == nothing)
  level_outer_given = !(level_outer == nothing)

  if s_given
    DEBUG = false
    N_s = length(s)
    N_AB = N_s
  else
    N_s = N_AB
    s = repeat('*', N_s)
  end
  if !level_given
    level_total = zeros(N_s)
  end
  if !level_outer_given
    level_outer = zeros(N_s)
  end

  L = Vector{Int64}(undef, 0)
  e = Vector{Int64}(undef, 0)
  (C, D) = Tuple([e, e])
  B_available = B
  if DEBUG
    print("\n ************************************************* Debugging get_alternating_consecutive_vector \n")
    print("A = ",A)
    print("\nB = ",B,"\n")
  end
  if length(A) > 0 && length(B) > 0
    b_previous = B[1]
    j_previous = 1
    for (i, a) in enumerate(A)
      found = false
      if DEBUG
        print("\n ----------------------------------- new B_available\n")
      end
      for (j, b) in enumerate(B_available)
        # cond_outer = level_outer_given ? level_outer[a]==level_outer[b] : true
        # cond_outer = level_outer_given ? level_outer[a]==1 && level_outer[b]==1 : true
        cond_outer = level_outer_given ? level_outer[a]==1 && level_outer[a-1]==0 && level_outer[b]==1 && level_outer[b+1]==0 : true
        cond_total = level_total[a]==level_total[b]
        # cond_incr = ( b > a && a > b_previous ) || ( b > a && a == A[1] )
        # cond_incr = (b > a) && ( a > b_previous || a == A[1] )
        cond_i1 = (b > a)
        cond_i2 = ( true || a == A[1] )
        cond_incr = cond_i1 && cond_i2
        # cond_incr = ( b > a && a > b_previous )
        cond_not_found = !found
        cond = cond_incr && cond_total && cond_outer && cond_not_found
        if DEBUG
          print("\n")
          print("a=", a)
          print(",b=", b)
          print(",cond_i1=", cond_i1)
          print(",cond_i2=", cond_i2)
          print(",lev_tot[",a,",",b,"]=", get_region(level_total, a),",", get_region(level_total, b))
          print(",lev_out[",a,",",b,"]=", get_region(level_outer, a),",", get_region(level_outer, b))
          print(",c(i, f, t, o)=", cond_incr, ", ", cond_not_found, ", ", cond_total, ", ", cond_outer)
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