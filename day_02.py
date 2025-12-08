#!/usr/bin/env python3

### problem one

"""
    id: int
    returns whether this is a valid id or not
"""
def idRepeatTwice(id):
    s = str(id)
    return s[:len(s)//2] == s[len(s)//2:] # for len(s) % 2 != 0, this will always evaluate to False

### problem two
def idRepeatArbitrary(id):
    s = str(id)
    idFilter = lambda n: s == n * s[:len(s)//n] # returns true if s is a repeat of n times the same expression
    return any(list(map(idFilter, range(2,len(s)+1))))

def rangeSum(idRange, isInvalid):
    firstId = int(idRange[0])
    lastId = int(idRange[1])
    return sum(filter(isInvalid, range(firstId, lastId+1)))

### input

with open('day_02-input', 'r') as file:
    sumTotal = 0

    ranges = []
    for line in file:
        rangeIds = line.strip().split(',')
        ranges.extend(list(map(lambda s: s.split('-'), rangeIds)))

    invalidOne = lambda idRange: rangeSum(idRange, idRepeatTwice)
    invalidTwo = lambda idRange: rangeSum(idRange, idRepeatArbitrary)
    print(sum(map(invalidOne, ranges)))
    print(sum(map(invalidTwo, ranges)))

