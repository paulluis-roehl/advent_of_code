#!/usr/bin/env python3

from functools import reduce

# problem one
def calculate(input):
    if input[-1] == '+':
        return reduce(lambda n, s: n + int(s), input[:-1], 0)
    elif input[-1] == '*':
        return reduce(lambda n, s: n * int(s), input[:-1], 1)
    pass

# problem two
def calculateII(input):
    (nums, op) = input
    return calculate([*nums, op])

def toInt(i):
    if i == ' ':
        return 0
    elif i == '':
        return 0
    return int(i)

def toNumbers(lines):
    nums = []
    row = []
    for i in range(len(lines[0])):
        digits = [lines[0][i], lines[1][i], lines[2][i], lines[3][i]]
        num = toInt(reduce(lambda s,c : s + c, digits, '').strip())
        if num == 0:
            nums.append(row)
            row = []
        else:
            row.append(num)
    return nums
        

# read input
with open('day_06-input', 'r') as file:
    lines = []
    linesII = []

    for line in file:
        lines.append(list(
            filter(lambda x: x != '',
                    line.split(' ')
            )
        ))
        linesII.append(list(line))

print(reduce(lambda n, l: n + calculate(l), zip(*lines), 0))

ops = list(
        filter(lambda x: x != '',
            line.split(' ')
        )
      )
newIn = list(zip(toNumbers(linesII), ops))
print(reduce(lambda n, l: n + calculateII(l), newIn, 0))
