#!/usr/bin/env python3

### problem one
def isRoll(grid, box):
    (i, j) = box
    return grid[i][j] == '@'

def numNeighbours(grid, box):
    lx = len(grid)
    ly = len(grid[0])
    (i, j) = box
    neighbours = 0
    if i > 0 and j > 0:
        neighbours += (grid[i-1][j-1] == '@')
    if i > 0:
        neighbours += (grid[i-1][j] == '@')
    if i > 0 and j < ly - 1:
        neighbours += (grid[i-1][j+1] == '@')
    if j > 0:
        neighbours += (grid[i][j-1] == '@')
    if j < ly - 1:
        neighbours += (grid[i][j+1] == '@')
    if j > 0 and i < lx - 1:
        neighbours += (grid[i+1][j-1] == '@')
    if i < lx - 1:
        neighbours += (grid[i+1][j] == '@')
    if i < lx - 1 and j < ly - 1:
        neighbours += (grid[i+1][j+1] == '@')
    return neighbours

### problem two
def numNeighboursII(rolls, box):
    (i, j) = box
    neighbours = 0
    neighbours += ((i-1, j-1) in rolls)
    neighbours += ((i-1, j  ) in rolls)
    neighbours += ((i-1, j+1) in rolls)
    neighbours += ((i  , j-1) in rolls)
    neighbours += ((i  , j+1) in rolls)
    neighbours += ((i+1, j-1) in rolls)
    neighbours += ((i+1, j  ) in rolls)
    neighbours += ((i+1, j+1) in rolls)
    return neighbours

### my own stuff... (horrible performance!)
def numNeighboursIII(rolls, box):
    (i, j) = box
    neighbours = set(filter(lambda b: abs(b[0] - i) <= 1 and abs(b[1] - j) <= 1 and not b == box, rolls))
    return len(neighbours)

# read input
with open('day_04-input', 'r') as file:
    grid = []

    for line in file:
        grid.append(list(line.strip()))

lx = len(grid)
ly = len(grid[0])

# part one
boxFilter = lambda box: (numNeighbours(grid, box) < 4) and isRoll(grid, box)
notBoxFilter = lambda box: not boxFilter(box)
print(len(list(filter(boxFilter, [(i, j) for i in range(0,lx) for j in range (0,ly)]))))


# part two
rolls = set(filter(lambda b: isRoll(grid, b), {(i, j) for i in range(0,lx) for j in range (0,ly)}))
removable = set(filter(lambda b: numNeighboursII(rolls, b) < 4, rolls))
print(len(removable))

numRolls = 0
while len(removable) > 0:
    numRolls += len(removable)
    rolls -= removable 
    removable = set(filter(lambda b: numNeighboursII(rolls, b) < 4, rolls))
print("Total removable:", numRolls)

"""
NOTE: this has a slightly shorter numNeighbours implementation, but is WAY WORSE in terms of runtime! (Don't use!)
# my own stuff
rolls = set(filter(lambda b: isRoll(grid, b), {(i, j) for i in range(0,lx) for j in range (0,ly)}))
removable = set(filter(lambda b: numNeighboursIII(rolls, b) < 4, rolls))
print(len(removable))

numRolls = 0
while len(removable) > 0:
    numRolls += len(removable)
    rolls -= removable 
    removable = set(filter(lambda b: numNeighboursIII(rolls, b) < 4, rolls))
print("Total removable:", numRolls)
"""
