using Agents
using Random
using InteractiveDynamics
using CairoMakie
using StaticArrays

include("./InteractingPairs.jl")
using .InteractingPairs

mutable struct Ball <: AbstractAgent
    id::Int                 # Mandatory Agent identifier
    pos::NTuple{2,Float64}  # Position, required for agents in the ContinuousSpace
    vel::NTuple{2,Float64}  # Moving speeds
    mass::Float64           # Can move or not
end

function ball_model(; speed=0.002, seed=42, nagents=500)
    area = nagents / 500
    side = sqrt(area)
    unitcell = (side, side)
    space2d = ContinuousSpace(unitcell; spacing=0.02, periodic=true)

    positions = [(side * rand(), side * rand()) for _ in 1:nagents]

    # Initialize InteracingPairs system
    system = InteractingPairs.init_system(
        positions=SVector.(positions),
        cutoff=0.012,
        unitcell=SVector(unitcell),
    )

    # Initialize model
    model = ABM(Ball, space2d, properties=Dict(:dt => 1.0, :system => system), rng=MersenneTwister(seed))

    # Add agents to the model
    for pos in positions
        vel = sincos(2π * rand(model.rng)) .* speed
        mass = 1.0
        add_agent!(pos, model, vel, mass)
    end
    return model
end

# Agent step
function agent_step!(agent, model)
    move_agent!(agent, model, model.dt)
    # Update positions in the PeriodicSystem structure
    model.properties[:system].positions[agent.id] = SVector(agent.pos)
end

# Model step 
function model_step!(model)
    for (i,j) in InteractingPairs.interacting_pairs(model.properties[:system], :nearest)
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
        "celllistmap_Elastic.mp4",
        model2,
        agent_step!,
        model_step!;
        title="Billiard-like",
        frames=100,
        spf=2,
        framerate=25
    )
end
