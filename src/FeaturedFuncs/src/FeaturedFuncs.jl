module FeaturedFuncs
using Plots

push!(LOAD_PATH, "./PerFlagFuncs/src/")
using PerFlagFuncs

export Flag
export FlagSet

svec = Vector{String}

struct Flag
  word :: String
  word_boundaries_left :: Vector{String}
  word_boundaries_right :: Vector{String}
  trigger :: Vector{String}
  function Flag(word, word_boundaries_left, word_boundaries_right)
    trigger = Vector{String}()
    for left in word_boundaries_left
      for right in word_boundaries_right
        push!(trigger, string(left, word, right))
      end
    end
    return new(word, word_boundaries_left, word_boundaries_right, trigger)
  end
end

struct FlagSet
  start :: Flag
  stop  :: Flag
  ID  :: String
  function FlagSet(start::Flag, stop::Flag)
    # return new(start, stop, start.word*stop.word)
    return new(start, stop, start.word)
  end
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

function compute_level_total(s::String, flags_start::svec, flags_stop::svec)
  L_s = length(s)
  level = zeros(Int, L_s)
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

function compute_level_per_flag(s::String, level_total::Vector{Int}, flag_set_all::Vector{FlagSet})
  # Algorithm:
  # 1) Initialize level_total_modified = level_total_total
  # 2) Find the maximum of level_total_modified and
  #    ask "Which key is responsible for the most recent
  #    increase in level_total_modified?" Assign the corresponding
  #    indexes in the dictionary.
  # 3) Set level_total_modified = level_total_modified-1
  #    where these dictionary indexes were set (since
  #    the solution in these locations are now known).
  # 4) Repeat 2-3 until level_total_modified = 0 everywhere
  DEBUG = false
  level_total_modified = copy(level_total)
  N = length(level_total)
  D = Dict(FS.ID => zeros(Int, N) for FS in flag_set_all)
  max_lev = max(level_total...)
  for i in max_lev:-1:1
    L_max = max(level_total_modified...)
    i_maxes = [i for (i, x) in enumerate(level_total_modified) if x==L_max]
    L_maxes = split_by_consecutives(i_maxes)
    if DEBUG
      plot([Float64(x) for x in 1:N], level_total)
      plot!(title = "level", xlabel = "character", ylabel = "level")
      png("level_total_iter_"*string(i))
    end
    for i_max in L_maxes
      for FS in flag_set_all
        cond_any = any([x==s[i_max[1]:i_max[1]+length(x)-1] for x in FS.start.trigger])
        if cond_any
          D[FS.ID][i_max] .+= 1
        end
      end
      level_total_modified[i_max].-= 1
    end
  end
  if DEBUG
    for FS in flag_set_all
      plot([Float64(x) for x in 1:N], D[FS.ID])
      plot!(title = "level_"*FS.ID, xlabel = "ith index", ylabel = "level")
      png("level_"*FS.ID)
    end
  end
  temp = [D[FS.ID] for FS in flag_set_all]
  level_total_check = sum(temp, dims=1)[1]
  err = [abs(x-y) for (x, y) in zip(level_total_check, level_total)]
  if DEBUG
    print("\nlength(level_total) = ", length(level_total))
    print("\nlength(level_total_check) = ", length(level_total_check))
    plot([Float64(x) for x in 1:N], level_total)
    plot!(title = "level_total", xlabel = "ith index", ylabel = "level")
    png("level_total")

    plot([Float64(x) for x in 1:N], level_total_check)
    plot!(title = "level_total_check", xlabel = "ith index", ylabel = "level")
    png("level_total_check")

    plot([Float64(x) for x in 1:N], err)
    plot!(title = "err", xlabel = "ith index", ylabel = "level")
    png("level_err")
    print("\nerr = ", err)
  end
  if !all([x<0.01 for x in err])
    error("Error: levels not conservative.")
  end
  return D
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

function get_between_flags(s::String, flags_start::svec, flags_stop::svec, inclusive::Bool = true)
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

function get_between_flags_level(s::String, flags_start::svec, flags_stop::svec, inclusive::Bool = true)
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

function get_between_flags_level_new(s::String, outer_flags::FlagSet, inner_flags::Vector{FlagSet}, inclusive::Bool = true)
  L = Vector{String}()
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
  level = compute_level_total(s, flags_start, flags_stop)
  level_outer = compute_level_total(s, outer_flags_start, outer_flags_stop)
  (L_start, L_stop) = get_alternating_consecutive_vector(L_start, L_stop, level, level_outer, s)
  for (i_start, i_stop) in zip(L_start, L_stop)
    b, m, a = substring_decomp_by_index(s, i_start, i_stop, flags_start, flags_stop, inclusive)
    push!(L, m)
  end
  return L
end

function get_between_flags_level_new_new(s::String, outer_flags::FlagSet, inner_flags::Vector{FlagSet}, inclusive::Bool = true)
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

end