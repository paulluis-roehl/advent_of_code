import Base: parse

struct State
  position::Int
  zeroes::Int
end
struct RotationI <: Function
  amount::Int
end
function (f::RotationI)(s::State)::State
  position = mod(s.position + f.amount, 100)
  zeroes = s.zeroes + (position == 0)
  State(position, zeroes)
end

struct RotationII <: Function
  amount::Int
end
function (f::RotationII)(s::State)::State
  position = (s.position + f.amount) # not normalised to [0:100]!
  zeroes = s.zeroes + abs(÷(position, 100)) + (sign(s.position) == -sign(position)) + (position == 0)
  State(mod(position, 100), zeroes)
end
#function (f::RotationII)(s::State)::State
#phi(x)= floor(Int, (x-1)/100)
#position = (s.position + f.amount) # not normalised to [0:100]!
##zeroes = s.zeroes + abs(phi(position) - phi(s.position))
#State(position, zeroes)
#end

function parse(f::Type{RotationI}, str::AbstractString)
  amount = (str[1] == 'L') ? -parse(Int, str[2:end]) : parse(Int, str[2:end])
  RotationI(amount)
end

function parse(f::Type{RotationII}, str::AbstractString)
  amount = (str[1] == 'L') ? -parse(Int, str[2:end]) : parse(Int, str[2:end])
  RotationII(amount)
end




# input
s = State(50, 0)
file = "day_01-input"

# problem one
turns = parse.(RotationI, readlines(file))
newStateI = foldl(|>, turns; init=s)
println(newStateI)

# problem two
turns = parse.(RotationII, readlines(file))
newStateII = foldl(|>, turns; init=s)
println(newStateII)

