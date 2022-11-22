import sys

filename = sys.argv[1]

c = 0
prev = None
with open(filename, 'r') as f:
    for line in f:
        line = line.strip()
        if line:
            i = int(line)
            if prev is None:
                prev = i
                continue
            elif i > prev:
                c += 1
            prev = i
print(c)
