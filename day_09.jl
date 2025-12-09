
struct Tiles
  locations::Vector{NTuple{2,Int}}
  num::Int
  areas::Dict{NTuple{2,Int},Int}
end
function Tiles(tiles::Vector{NTuple{2,Int}})
  num = length(tiles)
  areas = Dict()
  for i in 1:num-1, j in i+1:num
    areas[(i, j)] = *(abs.(tiles[i] .- tiles[j]) .+ 1...)
  end
  Tiles(tiles, num, areas)
end

# problem two
#function isInside(tiles::Tiles, tile::NTuple{2,Int})
#neighbours = zip(1:tiles.num, circshift(1:tiles.num, -1))
#map(n -> , neighbours)
#end

# input
file = "day_09-input"
tiles::Vector{NTuple{2,Int}} = []
for line in readlines(file)
  tile = tuple(map(x -> parse(Int, x), split(line, ','))...)
  push!(tiles, tile)
end

# problem one
t = Tiles(tiles)
connections = sort(collect(t.areas), by=x -> x.second, rev=true)
println(connections[1].second)
