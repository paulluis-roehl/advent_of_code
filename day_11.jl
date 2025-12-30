# graph just with connections (no distances)
struct Graph{T}
  vertices::Dict{T,Vector{T}}
end

"""
"flattens" the oriented graph into an ordered list
(the ordered list will not contain any nodes that are in a loop)
"""
function topologicalSort(graph::Graph{String})::Vector{String}
  sortedNodes = []
  loops = []

  unvisited = []
  temporary = [] # temporary mark (for finding loops)
  for (k, v) in graph.vertices
    push!(unvisited, k)
  end

  function visit(node::String)
    if node ∉ unvisited
      return
    end
    if node ∈ temporary
      println("found loop back to node \"", node, "\"")
      push!(loops, node)
      return
    end

    push!(temporary, node)

    for neighbour in graph.vertices[node]
      visit(neighbour)
    end

    filter!(≠(node), unvisited)
    filter!(≠(node), temporary)

    if node ∉ loops
      pushfirst!(sortedNodes, node)
    end
  end

  # makes sure to visit all disconnected components
  # (and independent of starting node, even if there are connections to it)
  while length(unvisited) > 0
    visit(unvisited[1])
  end

  return sortedNodes
end

"""
finds the number of paths between source and target in a graph.

!! Does no error handling: source and target must exist in graph (and be unique) !!
"""
function findAllPaths(graph::Graph{String}, source::String, target::String)
  numPaths = Dict() # number of paths from any node to target
  sortedNodes = topologicalSort(graph)
  s = findall(==(source), sortedNodes)[1]
  t = findall(==(target), sortedNodes)[1]
  if s > t
    return 0
  elseif s == t
    return 1
  end

  relevantNodes = sortedNodes[s:t-1]
  for node in relevantNodes
    numPaths[node] = 0
  end
  numPaths[target] = 1

  for node in Iterators.reverse(relevantNodes)
    for neighbour in graph.vertices[node]
      numPaths[node] += get(numPaths, neighbour, 0)
    end
  end

  return numPaths[source]
end

# parse input
file = "day_11-input"
vertices::Dict{String,Vector{String}} = Dict()
for line in readlines(file)
  nodes = split(line, ' ')
  source = nodes[1][1:end-1]
  targets = nodes[2:end]
  vertices[source] = targets
end
vertices["out"] = []
graph = Graph{String}(vertices)

# problem one
paths = findAllPaths(graph, "you", "out")
println("paths from you -> out: ", paths)

# problem two
allPaths = findAllPaths(graph, "svr", "out")
println("all paths from svr -> out: ", allPaths)
paths = findAllPaths(graph, "svr", "fft") * findAllPaths(graph, "fft", "dac") * findAllPaths(graph, "dac", "out")
println("paths via svr -> fft -> dac -> out: ", paths, " (", round(100 * paths / allPaths, digits=2), "% of all paths)")
paths = findAllPaths(graph, "svr", "dac") * findAllPaths(graph, "dac", "fft") * findAllPaths(graph, "fft", "out")
println("paths via svr -> dac -> fft -> out: ", paths, " (", round(100 * paths / allPaths, digits=2), "% of all paths)")

