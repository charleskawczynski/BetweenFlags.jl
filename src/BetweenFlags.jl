module BetweenFlags

using PerFlagFuncs

export Flag
export FlagSet

svec = Vector{String}

struct Flag
  word :: String
  word_boundaries_left :: Vector{String}
  word_boundaries_right :: Vector{String}
end

struct FlagSet
  start :: Flag
  stop  :: Flag
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

function compute_level(s::String, flags_start::svec, flags_stop::svec)
  level = zero(1:length(s))
  L_s = length(s)
  D_o = Dict(x => length(x) for x in flags_start)
  D_c = Dict(x => length(x) for x in flags_stop)
  L_c_arr = [v for (k, v) in D_o]
  L_o_arr = [v for (k, v) in D_c]
  L_delim_max = max([max(L_o_arr...), max(L_c_arr...)]...)
  L_delim_min = min([min(L_o_arr...), min(L_c_arr...)]...)
  if L_s>L_delim_min
    for i in 1:L_s-L_delim_max
      if any([s[i:i+D_o[x]-1] == x for x in flags_start])
        level[i:end] .= level[i:end] .+ 1
      elseif any([s[i:i+D_c[x]-1] == x for x in flags_stop])
        level[i+1:end] .= level[i+1:end] .- 1
      end
    end
  end
  return level
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
  if L_start==[] || L_stop==[]
    return []
  end
  (L_start, L_stop) = get_alternating_consecutive_vector(L_start, L_stop)
  for (i_start, i_stop) in zip(L_start, L_stop)
    b, m, a = substring_decomp_by_index(s, i_start, i_stop, flags_start, flags_stop, inclusive)
    push!(L, m)
  end
  return L
end

function get_level(s::String, flags_start::svec, flags_stop::svec, inclusive::Bool = true)
  L = Vector{String}(undef, 0)
  L_start = [m for flag_start in flags_start for m in find_next_iter(s, flag_start)]
  L_stop  = [m for flag_stop  in flags_stop  for m in find_next_iter(s, flag_stop )]
  sort!(L_start)
  sort!(L_stop)
  if L_start==[] || L_stop==[]
    return []
  end
  level = compute_level(s, flags_start, flags_stop)
  (L_start, L_stop) = get_alternating_consecutive_vector(L_start, L_stop, level)
  for (i_start, i_stop) in zip(L_start, L_stop)
    b, m, a = substring_decomp_by_index(s, i_start, i_stop, flags_start, flags_stop, inclusive)
    push!(L, m)
  end
  return L
end

function add_word_boundaries_flags_start(flag_set)
  flag_set_all = []
  flag_set_all = vcat(flag_set_all, [string(left, flag_set.start.word, right) for left  in flag_set.start.word_boundaries_left
                                                                              for right in flag_set.start.word_boundaries_right])
  return flag_set_all
end

function add_word_boundaries_flags_stop(flag_set)
  flag_set_all = []
  flag_set_all = vcat(flag_set_all, [string(left, flag_set.stop.word, right) for left  in flag_set.stop.word_boundaries_left
                                                                             for right in flag_set.stop.word_boundaries_right])
  return flag_set_all
end

function get_level_new(s::String, outer_flags::FlagSet, inner_flags::Vector{FlagSet}, inclusive::Bool = true)
  L = Vector{String}(undef, 0)
  out_flags_start = add_word_boundaries_flags_start(outer_flags)
  out_flags_stop = add_word_boundaries_flags_stop(outer_flags)
  in_flags_start = [add_word_boundaries_flags_start(x) for x in inner_flags]
  in_flags_stop = [add_word_boundaries_flags_stop(x) for x in inner_flags]

  flags_start = vcat(out_flags_start, in_flags_start)
  flags_stop  = vcat(out_flags_stop , in_flags_stop)
  L_start = [m for flag_start in flags_start for m in find_next_iter(s, flag_start)]
  L_stop  = [m for flag_stop  in flags_stop  for m in find_next_iter(s, flag_stop )]
  sort!(L_start)
  sort!(L_stop)
  if L_start==[] || L_stop==[]
    return []
  end
  level = compute_level(s, flags_start, flags_stop)
  level_outer = compute_level(s, out_flags_start, out_flags_stop)
  (L_start, L_stop) = get_alternating_consecutive_vector(L_start, L_stop, level, level_outer)
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
  (L_start, L_stop) = get_alternating_consecutive_vector(L_start, L_stop)
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