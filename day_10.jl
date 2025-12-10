import Base: parse

## utility
"""
creates a vector containing 2^n elements.
These elements are all possible n-vectors of booleans
"""
function boolean_vectors(n::Int)
  N = 1 << n
  out = Vector{Vector{Bool}}(undef, N)
  for k in 0:(N-1)
    v = Vector{Bool}(undef, n)
    for i in 1:n
      v[i] = ((k >> (n - i)) & 1) == 1
    end
    out[k+1] = v
  end
  out
end

"""
applies a button press to a BitVector
"""
function press(lights::BitVector, button::Vector{Int})
  newLights = copy(lights)
  for l in button
    newLights[l] = !newLights[l]
  end
  newLights
end

## structures
struct Graph{T}
  vertices::Vector{T}
  edges::Dict{NTuple{2,T},Int}
end

struct Machine
  lights::BitVector
  buttons::Vector{Vector{Int}}
  joltage::Vector{Int}
  graph::Graph{BitVector}
end
function Machine(lights, buttons, joltage)
  """
  creates a graph connecting light configurations by buttons
  """
  function toGraph(lights, buttons)::Graph{BitVector}
    vertices::Vector{BitVector} = boolean_vectors(length(lights))
    # = [collect(t) for t in Iterators.product(fill([true, false], length(m.lights))...)]
    edges::Dict{NTuple{2,BitVector},Int} = Dict()
    for button in buttons
      for v::BitVector in vertices
        edges[(v, press(v, button))] = 1
      end
    end
    Graph(vertices, edges)
  end

  graph = toGraph(lights, buttons)
  Machine(lights, buttons, joltage, graph)
end

"""
parse string into Machine struct
"""
function parse(f::Type{Machine}, str::AbstractString)
  """
  parseIntVector converts "n1,n2,n3,..." into [Int(n1), Int(n2), Int(n3), ...]
  """
  function parseIntVector(str::AbstractString, splitter::Char)
    parse.(Int, split(str, splitter))
  end
  parts = split(str, ' ')
  lights = BitVector(map(c -> c == '#' ? 1 : 0, collect(parts[1][2:end-1])))
  joltage = parseIntVector(parts[end][2:end-1], ',')
  # add +1 to buttons since julia starts indexing from 1
  buttons = map(λ -> parseIntVector(λ[2:end-1], ',') .+ 1, parts[2:end-1])
  Machine(lights, buttons, joltage)
end

## part one

"""
implementation of Dijkstra's algorithm to find optimal way to press buttons
"""
function findPath(graph::Graph{BitVector}, source::BitVector, target::BitVector)
  dist = Dict()
  #prev = Dict()
  Q = []
  for v in graph.vertices
    dist[v] = Inf
    push!(Q, v)
  end
  dist[source] = 0

  while !isempty(Q)
    sort!(Q, by=v -> dist[v])[1]
    u = popfirst!(Q)
    if u == target
      return dist[u]
    end

    for v in Q
      alt = dist[u] + get(graph.edges, (u, v), Inf)
      if alt < dist[v]
        dist[v] = alt
        #prev[v] = u
      end
    end
  end
  # return (dict, prev)
  return Inf
end


# parse input
file = "day_10-input"
machines::Vector{Machine} = []
graphs::Vector{Graph{Machine}} = []
for line in readlines(file)
  push!(machines, parse(Machine, line))
end

# problem one
println(sum(
  map(m -> findPath(m.graph,
      fill(false, length(m.lights)) |> BitVector, # zero element
      m.lights),
    machines)
))


"""
#str = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
str = "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}"
machine = parse(Machine, str)
#println(machine)
graph = findPath(toGraph(machine), fill(false, length(machine.lights)) |> BitVector, machine.lights)
println(graph)
"""
