import sys

p1 = 0
p2 = 0

with open(sys.argv[1], 'r') as f:
    for line in f:
        limits = [int(item) for sublist in [lim.split('-') for lim in line.strip().split(',')] for item in sublist]
        p1 += int( (limits[0] >= limits[2] and limits[1] <= limits[3]) or (limits[2] >= limits[0] and limits[3] <= limits[1]) )
        p2 += int( (limits[0] >= limits[2] and limits[0] <= limits[3]) or (limits[2] >= limits[0] and limits[2] <= limits[1]) )

print(p1, p2)
