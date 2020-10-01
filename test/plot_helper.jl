using Plots
function export_plot(
        token_stream,
        code;
        path::S,
        filename::S = "./scope_per_flag.png",
    ) where {S}
    ei = eachindex(code)
    plot()
    @inbounds for (flag, scope) in token_stream
        plot!([i for i in ei], scope, label=replace(flag, "\n" => ""))
    end
    scope_sum = [0 for i in ei]
    @inbounds for (flag, scope) in token_stream
        scope_sum .+= scope
    end
    plot!([i for i in ei], scope_sum, label="total scope", legend=:bottomleft)
    savefig(joinpath(path,filename))
end
