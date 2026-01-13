import Base: parse
using JuMP
using HiGHS
using LinearAlgebra

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
    sort!(Q, by=v -> dist[v])
    u = popfirst!(Q)
    if u == target
      return dist[u]
      # abort the remaining graph search if target reached
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

### part two

# I tried for a while using A* path finding, but I couldn't get it performant enough.
# So I used the fact that this can be re-formulated as a standard ILP problem and used those solvers

function buttonsToMatrix(buttons::Vector{Vector{Int}}, numLights::Int)
  A = zeros(Int, numLights, length(buttons))
  for i in 1:length(buttons)
    for j in buttons[i]
      A[j, i] = 1
    end
  end
  return A
end

function minJoltage(buttons::Vector{Vector{Int}}, target::Vector{Int})
  A = buttonsToMatrix(buttons, length(target))
  n = length(buttons)
  model = Model(HiGHS.Optimizer)
  set_silent(model)

  @variable(model, x[1:n] >= 0, Int)
  @objective(model, Min, sum(x))
  @constraint(model, A * x .== target)

  optimize!(model)

  #println("Status: ", termination_status(model))
  #println("x = ", value(x))
  #println("Objective = ", objective_value(model))

  return objective_value(model)
end

### deprecated:

# computes estimated distance of Vector
function estimator(source::Vector{Int}, target::Vector{Int})
  relativeDist = target - source
  if any(<(0), relativeDist)
    return Inf
  end
  return sum(relativeDist)
end

Node = Tuple{Vector{Int},Int}

function neighbourFunction(buttons::Vector{Vector{Int}}, target::Vector{Int})
  function getNeighbours(node::Node)
    (source, l) = node
    neighbours = []

    if l > length(buttons)
      return neighbours
    end

    t = copy(target)
    steps = minimum(keepat!(t - source, buttons[l]))
    for i in 0:steps
      neighbour = copy(source)
      for n in buttons[l]
        neighbour[n] += i
      end
      push!(neighbours, (neighbour, l + 1))
    end
    return neighbours
  end

  return getNeighbours
end

function aStar(source::Vector{Int}, target::Vector{Int}, nb, h)
  sourceNode = (source, 1)
  openSet = []
  push!(openSet, sourceNode)

  cameFrom = Dict() # previous node on cheapest known path
  gScore = Dict() # cost of currently cheapest known path to node
  gScore[sourceNode] = 0
  fScore = Dict() # estimated cost of full path
  fScore[sourceNode] = h(source, target)

  println("source: ", source)
  println("target: ", target)

  numNodes = 0

  while !isempty(openSet)
    numNodes += 1
    if mod(numNodes, 10000) == 0
      println(numNodes, " nodes checked")
    end
    sort!(openSet, by=v -> get(fScore, v, Inf))
    current = popfirst!(openSet)
    #println("node: ", first(current))
    #println("level: ", last(current))
    if first(current) == target
      println("target reached!")
      return true
    end

    for neighbour in nb(current)
      tentative_gScore = get(gScore, current, Inf) + 1
      if tentative_gScore < get(gScore, neighbour, Inf)
        cameFrom[neighbour] = current
        gScore[neighbour] = tentative_gScore
        fScore[neighbour] = tentative_gScore + h(first(neighbour), target)
        if neighbour ∉ openSet
          push!(openSet, neighbour)
        end
      end
    end
  end

  println("target couldn't be reached!")
  return false
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

# problem two
println("minJoltage:")
println(Int(sum(
  map(m -> minJoltage(m.buttons, m.joltage),
    machines)
)))
