####
#### tokenize
####

debug() = false
# export tokenize, get_string

function start_cond(nt, active_scope)
  if isempty(active_scope)
    return nt.flag isa StartFlag
  else
    if grep_type(nt.fp) === GreedyType
      return nt.flag isa StartFlag && last(active_scope) ≠ nt.ID
    else
      return nt.flag isa StartFlag
    end
  end
end
function stop_cond(nt, active_scope)
  if grep_type(nt.fp) === GreedyType
    if isempty(active_scope)
      return false
    else
      return nt.trig in nt.fp.stop.trigger
    end
  else
    if isempty(active_scope)
      return false
    else
      return nt.flag isa StopFlag
    end
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

    all_flags = []
    for x in flag_pairs
      for trig in (x.start.trigger...,)
        push!(all_flags, (fp=x, trig=trig, flag=x.start, ID=x.ID))
      end
      for trig in (x.stop.trigger...,)
        push!(all_flags, (fp=x, trig=trig, flag=x.stop, ID=x.ID))
      end
    end
    greedy_config = any([grep_type(nt.fp) isa GreedyType for nt in all_flags])

    # Convenience maps:
    trig2ID = Dict(nt.trig => nt.ID for nt in all_flags)
    ei = eachindex(code)
    ei_end = last(ei)
    token_stream = Dict()
    @inbounds for nt in all_flags
      token_stream[trig2ID[nt.trig]] = [0 for i in ei]
    end

    lenflags = length(all_flags)
    flens = length.([nt.trig for nt in all_flags])
    active_scope = []
    i = first(ei)
    i_max = max(ei...)
    @inbounds for i_base in ei
      debug() && println("------------------- i = $(i)")
      safe_end = min.(i .+ flens .- 1, ntuple( _ -> ei_end, lenflags))
      code_substrings = [code[i:j] for j in safe_end]
      debug() && @show code_substrings
      # Filter non-equal lengths:
      data = [(nt,code_substr) for
        (nt,code_substr) in
        zip(all_flags,code_substrings)
        if length(nt.trig)==length(code_substr)]
      # may be non-unique, greedy over start trigs
      # Three options:
      #  - 1) Close last active scope
      #  - 2) Open new scope
      #  - 3) Do nothing (no string match)
      for (nt,code_substr) in data
        trig = nt.trig
        if trig==code_substr
          debug() && println("*********** match")
          # Update token stream (option 1 or 2)
          debug() && @show nt.trig
          debug() && @show nt.ID
          debug() && @show grep_type(nt.fp)
          debug() && @show nt.flag
          debug() && @show nt.fp
          debug() && @show active_scope
          debug() && @show stop_cond(nt, active_scope)
          debug() && @show start_cond(nt, active_scope)

          if stop_cond(nt, active_scope)
            last_scope = last(active_scope)
            token_stream[last_scope][i+length(trig):end] .-= 1
            pop!(active_scope)
          elseif start_cond(nt, active_scope)
            token_stream[trig2ID[trig]][i:end] .+= 1
            push!(active_scope, trig2ID[trig])
          end
          # increment i to avoid double-counting
          # for variable flag lengths:
          i+=max(length(trig)-2, 0)
          debug() && println("***********")
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

