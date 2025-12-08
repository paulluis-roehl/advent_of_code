using LinearAlgebra

struct Boxes
  boxes::Dict{Int,Vector{Int}}
  num::Int
  distances::Dict{NTuple{2,Int},Float64}
end
function Boxes(boxes::Vector{Vector{Int}})
  num = length(boxes)
  boxesDict = Dict(1:num .=> boxes)
  distances = Dict()
  for i in 1:num-1, j in i+1:num
    distances[(i, j)] = norm(boxes[i] - boxes[j])
  end
  Boxes(boxesDict, num, distances)
end

mutable struct Circuits
  numBoxes::Int
  circuits::Vector{Set{Int}}
  Circuits(numBoxes) = new(numBoxes, Set.(1:numBoxes))
end

"""
  modifies a circuit by connecting two boxes
"""
function connect!(c::Circuits, box1::Int, box2::Int)
  i = findall(x -> box1 ∈ x || box2 ∈ x, c.circuits)
  if length(i) == 2
    union!(c.circuits[i[1]], c.circuits[i[2]])
    deleteat!(c.circuits, i[2])
  end
end

"""
  connects all given connections
  returns connected circuits, ordered from largest to smallest
"""
function connectAll!(c::Circuits, connections)
  for con in connections
    (b1, b2) = con.first
    connect!(c, b1, b2)
  end
  sort(c.circuits, by=x -> length(x), rev=true)
end

"""
  fully connects a circuit (shortest connections first)
  returns the index of the last to boxes connected
"""
function connectFully!(c::Circuits, connections)
  i = 1
  (b1, b2) = ([], [])
  while length(c.circuits) > 1
    (b1, b2) = connections[i].first
    connect!(c, b1, b2)
    i += 1
  end
  (b1, b2)
end

# input
file = "day_08-input"
boxes::Vector{Vector{Int}} = []
for line in readlines(file)
  box = map(x -> parse(Int, x), split(line, ','))
  push!(boxes, box)
end
b = Boxes(boxes)
connections = sort(collect(b.distances), by=x -> x.second)

# problem one
c = Circuits(b.num)
circuits = connectAll!(c, connections[1:1000])
println(*(length.(circuits)[1:3]...))

## problem two
c2 = Circuits(b.num)
(b1, b2) = connectFully!(c2, connections) # (index of) last two boxes to be connected
println(b.boxes[b1][1] * b.boxes[b2][1])

