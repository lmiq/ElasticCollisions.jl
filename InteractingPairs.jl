module InteractingPairs

using StaticArrays
using CellListMap.PeriodicSystems

# One pair
struct Pair{T}
    i::Int
    j::Int
    d::T
end

# Allow destructuring to use for (i,j) in Pair(1,2,0.0)
import Base: iterate
iterate(t::Pair, iter=1) = iter > nfields(t) ? nothing : (getfield(t, iter), iter + 1)

# Contains the number and list of pairs
mutable struct InteractingPairsVector{T}
    number_of_pairs::Int
    pairs::Vector{Pair{T}}
end

# Updates the list given the a new pair
function update_pairlist!(x::InteractingPairsVector, pair::Pair)
    # check if this pair replaces the best distance
    i = findfirst(
        p -> p.i == pair.i,
        @view(x.pairs[1:x.number_of_pairs])
    )
    if isnothing(i)
        x.number_of_pairs += 1
        if x.number_of_pairs <= length(x.pairs)
            x.pairs[x.number_of_pairs] = pair
        else
            push!(x.pairs, pair)
        end
    elseif x.pairs[i].d > pair.d
        x.pairs[i] = pair
    end
    return x
end

# Define methods necessary for threading
import CellListMap.PeriodicSystems: copy_output, reset_output!, reducer
copy_output(x::InteractingPairsVector) = InteractingPairsVector(x.number_of_pairs, copy(x.pairs))
function reset_output!(x::InteractingPairsVector)
    x.number_of_pairs = 0
    return x
end
function reducer(x::InteractingPairsVector, y::InteractingPairsVector)
    for pair in @view(y.pairs[1:y.number_of_pairs])
        update_pairlist!(x, pair)
    end
    return x
end

# This is the function mapped with map_pairwise!
function update_pairlist!(i, j, d2, x::InteractingPairsVector)
    d = sqrt(d2)
    pair = i < j ? Pair(i, j, d) : Pair(j, i, d)
    update_pairlist!(x, pair)
    return x
end

# Define the iterator over the interacting pairs of the periodic system

struct NearestPairsIterator{T}
    system::T
end

function interacting_pairs(system::PeriodicSystems.AbstractPeriodicSystem, s::Symbol)
    if s == :nearest
        NearestPairsIterator(system)
    else
        error(" not implemented ")
    end
end

import Base: iterate
function iterate(np::NearestPairsIterator)
    map_pairwise!(
        (x, y, i, j, d2, output) -> update_pairlist!(i, j, d2, output),
        np.system,
    )
    if length(np.system.interacting_pairs.number_of_pairs) >= 1
        return (np.system.interacting_pairs.pairs[1], 1)
    else
        return nothing
    end
end
function iterate(np::NearestPairsIterator, i::Int)
    if i < np.system.interacting_pairs.number_of_pairs
        i += 1
        return (np.system.interacting_pairs.pairs[i], i)
    else
        return nothing
    end
end

function init_system(;
    positions::Vector{<:SVector{N,T}},
    cutoff::T,
    unitcell::AbstractVecOrMat,
    parallel=true,
) where {N,T}
    interacting_pairs = InteractingPairsVector(0, Pair{T}[])
    system = PeriodicSystem(
        positions=positions,
        cutoff=cutoff,
        unitcell=unitcell,
        output=interacting_pairs,
        output_name=:interacting_pairs,
        parallel=parallel,
    )
    return system
end

end # module InteractingPairs
