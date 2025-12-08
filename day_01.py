#!/usr/bin/env python3

from itertools import accumulate
from functools import reduce

### problem one
def parseTurn(s):
    if s[0] == 'L':
        return - int(s[1:])
    elif s[0] == 'R':
        return int(s[1:])

def zeroes(l):
    return len(list(filter(lambda x: x == 0, l)))

### problem two (and one revamped)
"""
    reduceI : (state, turn) -> state

    where state = (location, number of zeroes)
"""
def reduceI(state, turn):
    (loc, zeroes) = state
    ln = (loc + parseTurn(turn))%100
    return (ln, zeroes + (ln == 0))

# wrong answers:
# 7088
# 7625
# 6942
# 10935
# ... I hate off-by-one errors in the algorithm
# right answer: 6530
def reduceII(state, turn):
    (loc, zeroes) = state
    ln = loc + parseTurn(turn)
    extra = 0 if (ln - loc > 0) else (ln%100 == 0) - (loc == 0)
    return (ln%100, zeroes + abs((ln // 100) - (loc // 100)) + extra)


with open('day_01-input', 'r') as file:
    turns = []

    for line in file:
        turns.append(line.strip())

print(zeroes(accumulate(turns, lambda p,n: (p + parseTurn(n))%100, initial=50)))

print(reduce(reduceI, turns, (50,0)))
print(reduce(reduceII, turns, (50,0)))

