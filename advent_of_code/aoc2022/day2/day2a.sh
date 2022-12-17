#!/bin/bash

#the order is rock, paper, scissors

score=0
while read line
do
  if [[ $line == "A Y" ]]; then score=$((score+8)) # win with paper = 6 + 2 = 8
    elif [[ $line == "A X" ]]; then score=$((score+4)) # draw with rock = 3 + 1 = 4
    elif [[ $line == "A Z" ]]; then score=$((score+3)) # lose with scissors = 0 + 3 = 3
    elif [[ $line == "B Z" ]]; then score=$((score+9)) # win with scissors = 6 + 3 = 9
    elif [[ $line == "B Y" ]]; then score=$((score+5)) # draw with paper = 3 + 2 = 5
    elif [[ $line == "B X" ]]; then score=$((score+1)) # lose with rock = 0 + 1 = 1
    elif [[ $line == "C X" ]]; then score=$((score+7)) # win with rock = 6 + 1 = 7
    elif [[ $line == "C Z" ]]; then score=$((score+6)) # draw with scissors = 3 + 3 = 6
    elif [[ $line == "C Y" ]]; then score=$((score+2)) # lose with paper = 0 + 2 = 2
  fi
done < $1

echo $score
