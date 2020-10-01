####
#### tokenize
####

debug() = false
# export tokenize, get_string

start_cond(flag_type) = flag_type isa StartType || flag_type isa GreedyType
function stop_cond(flag_type, active_scope, flag)
  if isempty(active_scope)
    return false
  else
    return flag_type isa StopType || flag_type isa GreedyType
  end
end

"""
    TokenStream(
        code::S,
        flag_set::FlagSet{FP}
    ) where {S<:AbstractString, FP<:FlagPair}

A dictionary whose keys are the flag IDs,
and whose values are vectors of `Int`s
indicating the nestedness of the flag.
"""
function TokenStream(
    code::S,
    flag_set::FlagSet{FP}
  ) where {S<:AbstractString, FP<:FlagPair}

  @inbounds begin
    flag_pairs = flag_set.flag_pairs
    greedy_config = any([
      x.start.flag_type isa GreedyType ||
      x.stop.flag_type isa GreedyType
      for x in flag_pairs for
        trig in [x.start.trigger...,x.stop.trigger...]])

    # Convenience maps:
    trig2ID = Dict(trig => x.ID for x in flag_pairs for trig in [x.start.trigger...,x.stop.trigger...])
    all_flags = [(x.start, x.stop) for x in flag_pairs]
    all_flags = collect(Iterators.flatten(all_flags))
    all_flags = [zip(x.trigger,ntuple(i->x.flag_type, length(x.trigger))) for x in all_flags]

    all_triggers = collect(Iterators.flatten(all_flags))
    ei = eachindex(code)
    ei_end = last(ei)
    token_stream = Dict()
    @inbounds for (trig,ft) in all_triggers
      token_stream[trig2ID[trig]] = [0 for i in ei]
    end

    trigs       = [trig for (trig,ft) in all_triggers]
    flag_types  = [ft for (trig,ft) in all_triggers]
    lenflags = length(trigs)
    flens = length.(trigs)
    active_scope = []
    i = first(ei)
    i_max = max(ei...)
    @inbounds for i_base in ei
      debug() && println("------------------- i = $(i)")
      safe_end = min.(i .+ flens .- 1, ntuple( _ -> ei_end, lenflags))
      code_substrings = [code[i:j] for j in safe_end]
      debug() && @show code_substrings
      # Filter non-equal lengths:
      data         = [(trig,code_substr,ft) for (trig,code_substr,ft) in zip(trigs,code_substrings,flag_types) if length(trig)==length(code_substr)]
      # may be non-unique, greedy over start trigs
      # Three options:
      #  - 1) Close last active scope
      #  - 2) Open new scope
      #  - 3) Do nothing (no string match)
      for (trig,code_substr,ft) in data
        if trig==code_substr
          # Update token stream (option 1 or 2)
          debug() && @show trig, ft
          if stop_cond(ft, active_scope, trig2ID[trig])
            last_scope = last(active_scope)
            token_stream[last_scope][i+length(trig):end] .-= 1
            if ft isa GreedyType
              token_stream[last_scope][i+length(trig):end] .=
                min.(token_stream[last_scope][i+length(trig):end], 0)
            end
            pop!(active_scope)
          elseif start_cond(ft)
            token_stream[trig2ID[trig]][i:end] .+= 1
            push!(active_scope, trig2ID[trig])
          end
          # increment i to avoid double-counting
          # for variable flag lengths:
          i+=max(length(trig)-2, 0)
          break # leave for loop
        end
      end
      i+=1
      i = min(i, i_max)
    end # for i in eachindex(code)

    if !greedy_config
      scope_sum = [0 for i in ei]
      @inbounds for (flag, scope) in token_stream
          scope_sum .+= scope
      end
      if last(scope_sum) != 0 && last(scope_sum) != 1
        @warn "Scope is not conserved"
      end
    end
  end

  return TokenStream(flag_set,code,token_stream)
end

"""
    (ts::TokenStream)(flag_id, cond=x->x>=1)

A `code` substring whose `TokenStream`, for
`flag_id`, satisfies the condition `cond`.
"""
function (ts::TokenStream)(flag_id, cond=x->x>=1)
  i_code = [i for i in 1:length(ts.code) if cond(ts.token_stream[flag_id][i])]
  return ts.code[i_code]
end

