#!/usr/bin/env python3

""" problem one
"""
def find_joltage2(bank):
    d1 = 0
    d2 = 0
    m = max(bank)
    i = bank.index(m)
    if i == len(bank) - 1:
        d2 = m
        d1 = max(bank[:-1])
    else:
        d1 = m
        d2 = max(bank[i+1:])

    return 10*d1+d2

""" problem two
"""
def find_joltage(bank, n):
    if n==1:
        return max(bank)
    elif n > 1:
        m = max(bank[:-n+1])
        i = bank[:-n+1].index(m)
        return m * 10**(n-1) + find_joltage(bank[i+1:], n-1)


with open('day_03-input', 'r') as file:
    banks = []

    for line in file:
        banks.append(list(map(int,list(line.strip()))))

### output

print("The total joltage for two batteries is:", sum(map(lambda b: find_joltage(b, 2),banks)))
print("The total joltage for twelve batteries is:", sum(map(lambda b: find_joltage(b, 12),banks)))

