using Agents
using Random
using InteractiveDynamics
using CairoMakie
using CellListMap.PeriodicSystems
using StaticArrays

mutable struct Ball <: AbstractAgent
    id::Int                 # Mandatory Agent identifier
    pos::NTuple{2,Float64}  # Position, required for agents in the ContinuousSpace
    vel::NTuple{2,Float64}  # Moving speeds
    mass::Float64           # Can move or not
end

struct Pair
    i::Int
    j::Int
    d::Float64
end

mutable struct InteractingPairs
    number_of_pairs::Int
    pairs::Vector{Pair}
end

function update_pair!(x::InteractingPairs, pair, i)
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

function update_pairlist!(x::InteractingPairs, pair::Pair)
    # check if this pair replaces the best distance for i
    i = findfirst(
        p -> p.i == pair.i,
        @view(x.pairs[1:x.number_of_pairs])
    )
    update_pair!(x, pair, i)
    return x
end

import CellListMap.PeriodicSystems: copy_output, reset_output!, reducer
copy_output(x::InteractingPairs) = InteractingPairs(x.number_of_pairs, copy(x.pairs))
function reset_output!(x::InteractingPairs)
    x.number_of_pairs = 0
    return x
end
function reducer(x::InteractingPairs, y::InteractingPairs)
    for pair in @view(y.pairs[1:y.number_of_pairs])
        update_pairlist!(x, pair)
    end
    return x
end

function update_pairlist!(i, j, d2, x::InteractingPairs)
    d = sqrt(d2)
    pair = i < j ? Pair(i, j, d) : Pair(j, i, d)
    update_pairlist!(x, pair)
    return x
end

function ball_model(; speed=0.002, seed=42, nagents=500)
    area = nagents / 500
    side = sqrt(area)
    unitcell = (side, side)
    space2d = ContinuousSpace(unitcell; spacing=0.02, periodic=true)

    positions = [(side * rand(), side * rand()) for _ in 1:nagents]
    interacting_pairs = InteractingPairs(0, Pair[])
    system = PeriodicSystem(
        positions=SVector.(positions),
        cutoff=0.012,
        unitcell=SVector(unitcell),
        output=interacting_pairs,
        output_name=:interacting_pairs,
        #parallel=false,
    )
    model = ABM(Ball, space2d, properties=Dict(:dt => 1.0, :system => system), rng=MersenneTwister(seed))

    # Add agents to the model
    for pos in positions
        vel = sincos(2π * rand(model.rng)) .* speed
        mass = 1.0
        add_agent!(pos, model, vel, mass)
    end
    return model
end

function agent_step!(agent, model)
    move_agent!(agent, model, model.dt)
    # Update positions in the PeriodicSystem structure
    model.properties[:system].positions[agent.id] = SVector(agent.pos)
end

# Billiard-like interaction
function model_step!(model)
    interacting_pairs = map_pairwise!(
        (x, y, i, j, d2, pair_list) -> update_pairlist!(i, j, d2, pair_list),
        model.properties[:system],
    )
    for ipair in 1:interacting_pairs.number_of_pairs
        i = interacting_pairs.pairs[ipair].i
        j = interacting_pairs.pairs[ipair].j
        elastic_collision!(model[i], model[j], :mass)
    end
end

function only_steps(; nsteps=100, model=ball_model(; nagents=500))
    Agents.step!(model, agent_step!, model_step!, nsteps, false)
    return model
end

function run0(; nagents=500)
    model2 = ball_model(; nagents=nagents)
    abmvideo(
        "celllistmap_ellastic.mp4",
        model2,
        agent_step!,
        model_step!;
        title="Billiard-like",
        frames=100,
        spf=2,
        framerate=25
    )
end
