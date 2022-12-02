import sys

score = 0
score_dict = {
    'X': 1,
    'Y': 2,
    'Z': 3,
    }

with open(sys.argv[1], 'r') as f:
    for line in f:
        words = line.split()
        opponent = words[0]
        me = words[1]

        if (opponent == 'A' and me == 'Y') or (opponent == 'B' and me == 'Z') or (opponent == 'C' and me == 'X'):
            # i win!
            score += 6
        elif (opponent == 'A' and me == 'X') or (opponent == 'B' and me == 'Y') or (opponent == 'C' and me == 'Z'):
            # draw
            score += 3

        score += score_dict[me]


        print(score, opponent, me)
