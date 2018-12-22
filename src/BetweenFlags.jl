module BetweenFlags

svec = Vector{String}

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

function get_alternating_consecutive_list(A::Vector{Int64}, B::Vector{Int64})
  L = Vector{Int64}(undef, 0)
  e = Vector{Int64}(undef, 0)
  (C, D) = Tuple([e, e])
  B_available = B
  if length(A) > 0 && length(B) > 0
    b_last = B[1]
    for a in A
      found = false
      for b in B_available
        if ( b > a && a > b_last ) || ( b > a && a == A[1] ) && !found
          push!(L, a)
          push!(L, b)
          B_available = [x for x in B_available if x > b_last]
          b_last = b
          found = true
        end
      end
    end
    C = L[1:2:end]
    D = L[2:2:end]
  end
  return Tuple([C, D])
end

function substring_decomp_by_index(s::String, i_start::Int, i_end::Int, flags_start::svec, flags_stop::svec, inclusive::Bool = true)
  if inclusive # middle and after depend on length of stop flag (LSTOP)...
    LSTOP = [length(x) for x in flags_stop if occursin(x, s[i_end:end])][1]
    before = s[1:i_start-1]
    middle = s[i_start:i_end+LSTOP-1]
    after = s[i_end+LSTOP:end]
  else # before and middle depend on length of start flag (LSTART)...
    LSTART = [length(x) for x in flags_start if occursin(x, s[1:i_start+length(x)])][1]
    before = s[1:i_start+LSTART-1]
    middle = s[i_start+LSTART:i_end-1]
    after = s[i_end:end]
  end
  return before, middle, after
end

function get_remaining_flags(s::String, flags_start::svec, flags_stop::svec)::Bool
  same_flags = all([x==y for x in flags_start for y in flags_stop])
  if same_flags
    remaining_flags = any([y in s for y in flags_start]) && any([y in s for y in flags_stop])
  else
    c_start = sum([count_flags(s, y) for y in flags_start])
    c_stop  = sum([count_flags(s, y) for y in flags_stop])
    if c_start == 0 || c_stop == 0
      remaining_flags = false
    else
      f_start = [findfirst(y, s)[1] for y in flags_start]
      f_stop  = [findfirst(y, s)[1] for y in flags_stop]
      remaining_flags = any([a<b for a in f_start for b in f_stop])
    end
  end
  return remaining_flags
end

function get(s::String, flags_start::svec, flags_stop::svec, inclusive::Bool = true)
  L = Vector{String}(undef, 0)
  L_start = [m for flag_start in flags_start for m in find_next_iter(s, flag_start)]
  L_stop  = [m for flag_stop  in flags_stop  for m in find_next_iter(s, flag_stop )]
  sort!(L_start)
  sort!(L_stop)
  (L_start, L_stop) = get_alternating_consecutive_list(L_start, L_stop)
  for (i_start, i_stop) in zip(L_start, L_stop)
    b, m, a = substring_decomp_by_index(s, i_start, i_stop, flags_start, flags_stop, inclusive)
    push!(L, m)
  end
  return L
end

function remove(s::String, flags_start::svec, flags_stop::svec, inclusive::Bool = true, reverse_order::Bool = false)
  """ remove_between_flags (RBF) is fundamentally different from get_between_flags (GBF) because
        the string, s, in GBF does not change, whereas it does in RBG. Therefore, the indexes found
        must, either be translated by the number of removed characters in the correct location, or
        the entire function must be called recursively. Alternatively, the strings/flags can be removed
        in reverse order, preserving the output string, which is what is done here."""
  if !get_remaining_flags(s, flags_start, flags_stop)
    return s
  end
  L_start = [m for flag_start in flags_start for m in find_next_iter(s, flag_start)]
  L_stop  = [m for flag_stop  in flags_stop  for m in find_next_iter(s, flag_stop )]
  sort!(L_start)
  sort!(L_stop)
  (L_start, L_stop) = get_alternating_consecutive_list(L_start, L_stop)
  s_new = s
  for (i_start, i_stop) in zip(reverse(L_start), reverse(L_stop))
    b, m, a = substring_decomp_by_index(s_new, i_start, i_stop, flags_start, flags_stop, inclusive)
    s_new = string(b, a)
  end
  if length(s_new)>length(s)
    print("\n-------------------------------- Error: Output string cannot be larger than input string\n")
    print("\nlength(s)     = {}", length(s))
    print("\nlength(s_new) = {}", length(s_new))
    print("\n -------------------------------- \n")
    print("\n", flags_start, flags_stop)
    print("\n -------------------------------- \n")
    print("\n", L_start, L_stop)
    print("\n -------------------------------- \n")
    print("\n", s)
    print("\n -------------------------------- \n")
    print("\n", s_new)
    print("\n -------------------------------- \n")
    error("Output string cannot be larger than input string")
  end
  return s_new
end

# function break_single_line(s_0::String, n_max_characters::Int64)
#   s = s_0
#   result = [s]
#   if (length(s) >= n_max_characters && !occursin(";", s_0))
#     potential_break_locations = [","]
#     # potential_break_locations = [')','(',',']
#     PBL = potential_break_locations
#     n_spaces = length(s) - length(s.lstrip(' '))
#     spaces = n_spaces*" "
#     s_max = s[0:n_max_characters]
#     if any(x in s_max for x in PBL)
#       cutoff = [s_max.rfind(x)+1 for x in PBL]
#       cutoff = min([x for x in cutoff if !(x==0)])
#       s_cut = s_max[0:cutoff] + "&"
#       s_remain = s[cutoff:]
#       if (s_remain == "&")
#         s_remain = ""
#       end
#       result = [s_cut]
#       if !(length(s_remain.replace(" ","")) <= 0)
#         result = result + break_single_line(spaces + s_remain)
#       end
#     end
#   else
#     result = [s]
#   end
#   return result
# end

# function break_single_line_once(s_0)
#   return break_single_line(s_0)
# end

# function get_n_leading_white_spaces(L)
#   temp = [length(x)-length(x.lstrip()) for x in L if (not x=='') and x]
#   if temp:
#     if (length(temp)==1):
#       if temp[0]==0:
#         temp = 0
#     else:
#       temp = min(temp)
#   else:
#     temp = 0
#   return temp
# end

# function indent_lines(L, indent)
#   n_leading_white_space = get_n_leading_white_spaces(L)
#   L = [x.lstrip() for x in L]
#   T_up = ('if ','type ','subroutine ','function ','do ')
#   T_dn = ('endif','end type','end subroutine','end function','enddo','end module')
#   T_unindent = ['else','elseif']
#   indent_cumulative = ''
#   s_indent = length(indent)
#   temp = ['' for x in L]
#   for i,x in enumerate(L):
#     if x.startswith(T_dn):
#       indent_cumulative = indent_cumulative[s_indent:]
#     temp[i]=indent_cumulative+temp[i]
#     if x.startswith(T_up):
#       indent_cumulative = indent_cumulative + indent
#   L = [s+x for (s,x) in zip(temp,L)]

#   L_new = []
#   for x in L
#     push!(L_new, break_single_line_once(x))
#   end

#   L = L_new
#   # L = [break_single_line(x) for x in L]
#   L = [item for sublist in L for item in sublist]
#   L = [x[s_indent:] if any([y in x for y in T_unindent]) else x for x in L]
#   L = [n_leading_white_space*' '+x if not x=='' else x for x in L]
#   return L
# end

end