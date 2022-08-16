using Agents
using Random
using InteractiveDynamics
using CairoMakie

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
    space2d = ContinuousSpace(unitcell; spacing=0.02)
    model = ABM(Ball, space2d, properties=Dict(:dt => 1.0), rng=MersenneTwister(seed))

    # Add agents to the model
    for i in 1:nagents
        pos = Tuple(side * rand(model.rng, 2))
        vel = sincos(2π * rand(model.rng)) .* speed
        mass = 1.0
        add_agent!(pos, model, vel, mass)
    end
    return model
end

agent_step!(agent, model) = move_agent!(agent, model, model.dt)

# Billiard-like interaction
function model_step!(model)
    for (a1, a2) in interacting_pairs(model, 0.012, :nearest)
        elastic_collision!(a1, a2, :mass)
    end
end

function only_steps(; nsteps=100, model=ball_model(; nagents=500))
    Agents.step!(model, agent_step!, model_step!, nsteps, false)
    return model
end

function run0(; nagents=500)
    model2 = ball_model(; nagents=nagents)
    abmvideo(
        "socialdist2.mp4",
        model2,
        agent_step!,
        model_step!;
        title="Billiard-like",
        frames=50,
        spf=2,
        framerate=25
    )
end