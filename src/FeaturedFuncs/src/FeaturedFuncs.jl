module FeaturedFuncs

root_dir = string(@__DIR__)
push!(LOAD_PATH, root_dir*"../../PerFlagFuncs/src/")
using PerFlagFuncs
push!(LOAD_PATH, root_dir)
using UtilityFuncs

export Flag
export FlagSet

export get_between_flags_flat
export get_between_flags_level
export get_between_flags_level_flat
export remove_between_flags_flat

function get_between_flags_flat(s::String, flags_start::svec, flags_stop::svec, inclusive::Bool = true)
  L = Vector{String}()
  L_start = [m for flag_start in flags_start for m in find_next_iter(s, flag_start)]
  L_stop  = [m for flag_stop  in flags_stop  for m in find_next_iter(s, flag_stop )]
  sort!(L_start)
  sort!(L_stop)
  if L_start==[] || L_stop==[]
    return L
  end
  (L_start, L_stop) = get_alternating_consecutive_vector(L_start, L_stop)
  for (i_start, i_stop) in zip(L_start, L_stop)
    b, m, a = substring_decomp_by_index(s, i_start, i_stop, flags_start, flags_stop, inclusive)
    push!(L, m)
  end
  return L
end

function get_between_flags_level_flat(s::String, flags_start::svec, flags_stop::svec, inclusive::Bool = true)
  L = Vector{String}()
  L_start = [m for flag_start in flags_start for m in find_next_iter(s, flag_start)]
  L_stop  = [m for flag_stop  in flags_stop  for m in find_next_iter(s, flag_stop )]
  L_start = unique(L_start)
  L_stop = unique(L_stop)
  sort!(L_start)
  sort!(L_stop)
  if L_start==[] || L_stop==[]
    return L
  end
  level = compute_level_total(s, flags_start, flags_stop)
  (L_start, L_stop) = get_alternating_consecutive_vector(L_start, L_stop, level)
  for (i_start, i_stop) in zip(L_start, L_stop)
    b, m, a = substring_decomp_by_index(s, i_start, i_stop, flags_start, flags_stop, inclusive)
    push!(L, m)
  end
  return L
end

function get_between_flags_level(s::String, outer_flags::FlagSet, inner_flags::Vector{FlagSet}, inclusive::Bool = true)
  L = Vector{String}()
  flag_set_all = vcat([outer_flags], inner_flags)
  outer_flags_start = outer_flags.start.trigger
  outer_flags_stop = outer_flags.stop.trigger
  inner_flags_start = [y for x in inner_flags for y in x.start.trigger]
  inner_flags_stop  = [y for x in inner_flags for y in x.stop.trigger]

  flags_start = vcat(outer_flags_start, inner_flags_start)
  flags_stop  = vcat(outer_flags_stop , inner_flags_stop)
  L_start = [m for flag_start in flags_start for m in find_next_iter(s, flag_start)]
  L_stop  = [m for flag_stop  in flags_stop  for m in find_next_iter(s, flag_stop )]
  L_start = unique(L_start)
  L_stop = unique(L_stop)
  sort!(L_start)
  sort!(L_stop)
  if L_start==[] || L_stop==[]
    return L
  end
  level_total = compute_level_total(s, flags_start, flags_stop)
  level_per_flags = compute_level_per_flag(s, level_total, flag_set_all)
  level_outer = level_per_flags[outer_flags.ID]
  (L_start, L_stop) = get_alternating_consecutive_vector(L_start, L_stop, level_total, level_outer, s)
  for (i_start, i_stop) in zip(L_start, L_stop)
    b, m, a = substring_decomp_by_index(s, i_start, i_stop, flags_start, flags_stop, inclusive)
    push!(L, m)
  end
  return L
end

function remove_between_flags_flat(s::String, flags_start::svec, flags_stop::svec, inclusive::Bool = true, reverse_order::Bool = false)
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

end