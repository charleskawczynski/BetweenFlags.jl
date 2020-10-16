####
#### tokenize
####

debug() = false

is_start_cond(nt, active_scope) =
    is_start_cond(grep_type(nt.fp), nt.flag, nt.ID, active_scope)

is_start_cond(gt::Type{GreedyType}, ::StartFlag, ID, active_scope) =
    isempty(active_scope) ? true : last(active_scope) ≠ ID
is_start_cond(gt, ::StopFlag, args...) = false
is_start_cond(gt, ::StartFlag, args...) = true

is_stop_cond(nt, active_scope) =
    is_stop_cond(grep_type(nt.fp), nt.flag, active_scope)
is_stop_cond(gt, ::StartFlag, active_scope) = false
is_stop_cond(gt, ::StopFlag, active_scope) =
    isempty(active_scope) ? false : true

function substr(s,i,j)
    try
      ss = SubString(s, i, j)
    catch
      # bad unicode ending, return
      # nothing for error handling.
      return nothing
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


The token stream is incremented
with a vector of Int's:

scope⁺          |  |      |
            |------------------------>
scope⁻                 |        |  |

                    ___    _____
                 __|   |__|     |__
            |   |                  |
scope       |------------------------>

"""
function TokenStream(
    code::S,
    flag_set::FlagSet{FP};
    rm_outer_bcs = false
  ) where {S<:AbstractString, FP<:FlagPair}

  @inbounds begin
    flag_pairs = flag_set.flag_pairs

    all_flags = NamedTuple[]
    for x in flag_pairs
      for (wb, trig) in x.start.trigger
        push!(all_flags, (fp=x, trig=trig, flag=x.start, ID=x.ID,
          len_b_left=length(wb[1]), len_b_right=length(wb[2])))
      end
      for (wb, trig) in x.stop.trigger
        push!(all_flags, (fp=x, trig=trig, flag=x.stop, ID=x.ID,
          len_b_left=length(wb[1]), len_b_right=length(wb[2])))
      end
    end
    greedy_config = any([grep_type(fp) isa GreedyType for fp in flag_pairs])

    # Convenience maps:
    ei = eachindex(code)
    i_max = max(ei...)
    ei_end = last(ei)
    token_stream = Dict{String,Vector{Int}}()
    token_stream⁺ = Dict{String,Vector{Int}}()
    token_stream⁻ = Dict{String,Vector{Int}}()
    @inbounds for fp in flag_pairs
      token_stream[fp.ID] = Int[0 for i in 1:i_max]
      token_stream⁺[fp.ID] = Int[0 for i in 1:i_max]
      token_stream⁻[fp.ID] = Int[0 for i in 1:i_max]
    end

    overlap_trigs = Dict{String,Bool}(nt.ID => false for nt in all_flags)
    for x in flag_pairs
      for trig in values(x.start.trigger)
        overlap_trigs[x.ID] = any(trig==x for x in values(x.stop.trigger))
      end
    end

    trig_lens = length.(Set([nt.trig for nt in all_flags]))
    active_scope = String[]
    i = first(ei)

    @inbounds for i_base in ei
      it = iterate(code, i)
      it == nothing && break
      debug() && println("------------------- i = $(i)")
      # Filter non-equal lengths:
      # may be non-unique, greedy over start trigs
      # Three options:
      #  - 1) Close last active scope
      #  - 2) Open new scope
      #  - 3) Do nothing (no string match)
      @inbounds for nt in all_flags
        ID = nt.ID
        trig = nt.trig
        L_trig = length(trig)
        @inbounds for trig_len in trig_lens
          safe_end = min(i + trig_len - 1, ei_end)
          if L_trig ≠ safe_end-i+1
            # No chance for match
            continue
          end
          code_substr = substr(code, i, safe_end)
          code_substr==nothing && break
          if trig==code_substr
            debug() && println("*********** match")
            # Update token stream (option 1 or 2)
            debug() && @show trig
            debug() && @show ID
            debug() && @show grep_type(nt.fp)
            debug() && @show nt.flag
            debug() && @show nt.fp
            debug() && @show active_scope
            debug() && @show is_stop_cond(nt, active_scope)
            debug() && @show is_start_cond(nt, active_scope)

            # Is true in all tests:
            stop_cond = is_stop_cond(nt, active_scope)
            start_cond = is_start_cond(nt, active_scope)
            if stop_cond
              if rm_outer_bcs
                i_mod = min(i+L_trig-nt.len_b_right, i_max)
              else
                i_mod = min(i+L_trig, i_max)
              end
              token_stream⁺[pop!(active_scope)][i_mod] = -1
            elseif start_cond
              if rm_outer_bcs
                i_mod = i+nt.len_b_left
              else
                i_mod = i
              end
              token_stream⁻[ID][i_mod] = 1
              push!(active_scope, ID)
            end
            if (stop_cond==start_cond==false) && overlap_trigs[ID]
              # Need to check if triggers match for complement flag
              continue
            end
            # increment i to avoid double-counting
            # for variable flag lengths:
            for k in 1:max(L_trig-1, 0)
              it = iterate(code, i)
              it == nothing && break
              i = it[2]
            end

            debug() && println("***********")
            break # leave for loop
          end # trig==code_substr
        end # for trig_len in trig_lens
      end # for nt in all_flags
      it = iterate(code, i)
      it == nothing && break
      i = it[2]
    end # for i in eachindex(code)

    for fp in flag_pairs
      ID = fp.ID
      token_stream[ID] = cumsum(token_stream⁺[ID] .+ token_stream⁻[ID])
    end

    if !greedy_config
      scope_sum = [0 for i in 1:i_max]
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
  i_code = [i for i in eachindex(ts.code) if cond(ts.token_stream[flag_id][i])]
  return join([substr(ts.code, i, i) for i in i_code])
end

