module Cutaway

using StatsBase

export CutHist, Cut


struct Cut
    f::Function
	label::AbstractString
	description::AbstractString
end


struct CutHist{H<:StatsBase.AbstractHistogram} 
    h::H
	cuts::Vector{Cut}
    hcuts::Vector{H}
	function CutHist(h::H, cuts::Vector{Cut}) where H<:StatsBase.AbstractHistogram
		n = length(cuts)
		hcuts = Vector{H}()
		for _ in 1:n
			push!(hcuts, deepcopy(h))
		end
		new{H}(h, cuts, hcuts)
	end
end


function Base.push!(chist::CutHist, x, context)
    push!(chist.h, x)
    for (cut, h) in zip(chist.cuts, chist.hcuts)
		cut.f(context) || continue
		push!(h, x)
	end
    chist
end


function Base.show(io::IO, c::CutHist)
	n = length(c.cuts)
	print(io, "CutHist($(n) cuts)")
end

end
