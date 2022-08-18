# ElasticCollisions.jl
example of Elastic collision simulations using Agents and CellListMap

## Without CellListMap.jl

```julia
julia> include("./Elastic.jl")

julia> only_steps(model = ball_model(nagents=500)); # compile

julia> @time only_steps(model = ball_model(nagents=2000));
  0.374590 seconds (3.32 M allocations: 279.059 MiB, 25.02% gc time)

julia> @time only_steps(model = ball_model(nagents=32000));
 15.027114 seconds (53.48 M allocations: 21.884 GiB, 32.97% gc time)

julia> @time only_steps(model = ball_model(nagents=128000));
402.776787 seconds (212.93 M allocations: 315.183 GiB, 78.49% gc time)
```

## With CellListMap.jl

Benchmarks do not include compilation time.

```julia
julia> include("./Elastic_celllistmap.jl")

julia> only_steps(model = ball_model(nagents=500)); # compile

julia> @time only_steps(model = ball_model(nagents=2000));
  0.068423 seconds (776.01 k allocations: 50.143 MiB)

julia> @time only_steps(model = ball_model(nagents=32000));
  2.016708 seconds (12.88 M allocations: 770.866 MiB, 9.67% gc time)

julia> @time only_steps(model = ball_model(nagents=128000));
  8.988287 seconds (51.79 M allocations: 3.014 GiB, 11.81% gc time)
```
