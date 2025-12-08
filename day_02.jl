# problem one
function stringToRange(s)
  (i, o) = parse.(Int, split(s, '-'))
  i:o
end

# problem two
function isRepeat(s::String, n::Int=2)
  s == s[1:length(s)÷n]^n
end

function isRepeat(s::String)
  any(map(n -> isRepeat(s, n), 2:length(s)))
end

# input
file = "day_02-input"
f = open(file, "r")
ranges = map(stringToRange,
  split(strip(read(f, String)), ",")
)
close(f)

# problem one
invalid = map(r -> filter(x -> isRepeat(string(x), 2), r), ranges)
println(sum(sum.(invalid)))

# problem two
invalid = map(r -> filter(isRepeat ∘ string, r), ranges)
println(sum(sum.(invalid)))
