#!/usr/bin/env python3

from functools import reduce

### problem one
def isFresh(freshIds, id):
    return any(list(map(lambda r: id in r, freshIds)))

### problem two
"""
make sure the ranges are not overlapping
"""
def atomise(freshIds):
    starts = list(map(lambda r: (r[0],    True ), freshIds))
    ends   = list(map(lambda r: (r[-1]+1, False), freshIds))
    # the key sorts by range start / end first and, if two with the same, sorts starts before ends
    oldEdges  = sorted(starts + ends, key=lambda x : x[0] - 0.5 * x[1])
    atomisedEdges = list()
    ## stacks
    numTrue = 0
    numFalse = 0
    # simplifies all overlapping id ranges
    for (n, v) in oldEdges:
        if v:
            if numTrue == 0:
                atomisedEdges.append((n, v))
            elif numTrue >= 1:
                numFalse += 1
            numTrue += 1
        else:
            if numFalse == 0:
                atomisedEdges.append((n, v))
            if numFalse >= 1:
                numFalse -= 1
            numTrue -= 1

    newRanges = []
    for i in range(len(atomisedEdges)//2):
        ri = atomisedEdges[2*i][0]
        ro = atomisedEdges[2*i+1][0]
        newRanges.append(range(ri, ro))
    return newRanges


        
print(atomise([range(1,6+1), range(3,8+1), range(8,12+1)]))
    

# read input
with open('day_05-input', 'r') as file:
    fresh = []
    available = []
    parseFresh = True

    for line in file:
        if parseFresh:
            if line.strip() == '':
                parseFresh = False
            else:
                (ri, rf) = line.strip().split('-')
                fresh.append(range(int(ri), int(rf)+1))
        else:
            available.append(int(line.strip()))

# problem one
print(len(list(filter(lambda id: isFresh(fresh, id), available))))
#print(fresh)

# problem two
# this is conceptually right, but computationally so bad that my laptop will terminate the process
"""
print(len(
      reduce(lambda s, r: s|set(r),
        fresh,
        set())
))
"""
atomised = atomise(fresh)
print(len(list(filter(lambda id: isFresh(atomised, id), available))))
print(reduce(
    lambda n, r: n + len(r),
    atomised,
    0
))
