import sys

i = 1
x = 1

with open(sys.argv[1], 'r') as f:
    for line in f:
        print(f'{line.strip()}, op: {i}, x: {x}')
        if line[0] == 'a':
            words = line.split()
            x += int(words[-1])


        i += 1
        if line[0] == 'a':
            i += 1
