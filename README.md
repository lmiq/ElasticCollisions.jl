# EllasticCollisions.jl
example of ellastic collision simulations using Agents and CellListMap

## Without CellListMap.jl

```julia-repl
julia> model = ball_model(nagents=2000)
AgentBasedModel with 2000 agents of type Ball
 space: periodic continuous space with (2.0, 2.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt

julia> @time only_steps(model=model)
  1.585200 seconds (8.49 M allocations: 569.603 MiB, 9.12% gc time, 78.18% compilation time)
AgentBasedModel with 2000 agents of type Ball
 space: periodic continuous space with (2.0, 2.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt

julia> model = ball_model(nagents=32000)
AgentBasedModel with 32000 agents of type Ball
 space: periodic continuous space with (8.0, 8.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt

julia> @time only_steps(model=model)
 14.389449 seconds (53.07 M allocations: 21.860 GiB, 31.82% gc time)
AgentBasedModel with 32000 agents of type Ball
 space: periodic continuous space with (8.0, 8.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt


```

## With CellListMap.jl

```julia-repl
julia> @time model = ball_model(nagents=2000)
  0.005228 seconds (40.12 k allocations: 8.026 MiB)
AgentBasedModel with 2000 agents of type Ball
 space: periodic continuous space with (2.0, 2.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt, system

julia> @time only_steps(model=model)
  0.084025 seconds (742.71 k allocations: 42.566 MiB, 17.62% compilation time)
AgentBasedModel with 2000 agents of type Ball
 space: periodic continuous space with (2.0, 2.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt, system

julia> @time model = ball_model(nagents=32000)
  0.110108 seconds (630.06 k allocations: 119.993 MiB, 19.63% gc time)
AgentBasedModel with 32000 agents of type Ball
 space: periodic continuous space with (8.0, 8.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt, system

julia> @time only_steps(model=model)
  1.838847 seconds (12.20 M allocations: 649.186 MiB, 5.67% gc time)
AgentBasedModel with 32000 agents of type Ball
 space: periodic continuous space with (8.0, 8.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt, system

julia> @time model = ball_model(nagents=128000)
  0.435038 seconds (2.51 M allocations: 475.874 MiB, 12.49% gc time)
AgentBasedModel with 128000 agents of type Ball
 space: periodic continuous space with (16.0, 16.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt, system

julia> @time only_steps(model=model)
  8.337330 seconds (49.19 M allocations: 2.544 GiB, 9.23% gc time, 0.06% compilation time)
AgentBasedModel with 128000 agents of type Ball
 space: periodic continuous space with (16.0, 16.0) extent and spacing=0.02
 scheduler: fastest
 properties: dt, system
```
