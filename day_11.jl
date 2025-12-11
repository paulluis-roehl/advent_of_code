
# graph just with connections (no distances)
struct Graph{T}
  vertices::Dict{T,Vector{T}}
end


"""
implementation of Dijkstra's algorithm to find optimal way to press buttons
"""
function findPaths(graph::Graph{String}, source::String, target::String)
  numPaths = 0

  dist = Dict()
  reaches = Dict()
  Q = []
  for (v, c) in graph.vertices
    dist[v] = Inf
    reaches[v] = 0
    push!(Q, v)
  end
  dist[source] = 0
  reaches[source] = 1

  while !isempty(Q)
    sort!(Q, by=v -> dist[v])
    u = popfirst!(Q)

    for v in graph.vertices[u]
      alt = dist[u] + 1
      reaches[v] += reaches[u]
      if alt < dist[v]
        dist[v] = alt
      end
    end
  end
  # return (dict, prev)
  reaches[target]
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
println("paths: ", findPaths(graph, "you", "out"))
