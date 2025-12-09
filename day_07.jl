
# problem one
struct Beam
  tachyons::Set{Int}
  splits::Int
end

function propagate(b::Beam, row::String)
  newTachyons = Set()
  splits = b.splits
  for t in b.tachyons
    if row[t] == '^'
      splits += 1
      if t > 1
        push!(newTachyons, t - 1)
      end
      if t < length(row)
        push!(newTachyons, t + 1)
      end
    else
      push!(newTachyons, t)
    end
  end
  Beam(newTachyons, splits)
end

# problem two
struct BeamII
  tachyons::Dict{Int,Int}
  splits::Int
end

function propagateII(b::BeamII, row::String)
  newTachyons = Dict()
  splits = b.splits
  for (k, v) in b.tachyons
    if row[k] == '^'
      splits += 1
      newTachyons[k-1] = get(newTachyons, k - 1, 0) + v
      newTachyons[k+1] = get(newTachyons, k + 1, 0) + v
    else
      newTachyons[k] = get(newTachyons, k, 0) + v
    end
  end
  BeamII(newTachyons, splits)
end

file = "day_07-input"
map = readlines(file)
start = findfirst(x -> x == 'S', collect(map[1]))
println(start)
beam = Beam(Set(start), 0)
beamEnd = foldl((b, row) -> propagate(b, row), map[2:end]; init=beam)
println(beam)
println(beamEnd)

## problem two
beamII = BeamII(Dict(start => 1), 0)
beamEndII = foldl((b, row) -> propagateII(b, row), map[2:end]; init=beamII)
println(beamII)
println(beamEndII)
println(sort(collect(beamEndII.tachyons), by=x -> x[1]))

function counttachs(b::BeamII)
  t = 0
  for (k, v) in beamEndII.tachyons
    t += v
  end
  t
end

# > 109058
println(counttachs(beamEndII))
