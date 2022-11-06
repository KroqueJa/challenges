# challenges
Online coding challenges of different kinds.

# Project Euler
Well-known [math problems](https://projecteuler.net/) of varying difficulty.

## Problem 1
A warmup problem; we make sure not to double count multiples of both 3 and 5. It's fizzbuzz!

# Codewars

## Split Strings
Complete the solution so that it splits the string into pairs of two characters. If the string contains an odd number of characters then it should replace the missing second character of the final pair with an underscore ('_').

Examples:
```
'abc' =>  ['ab', 'c_']
'abcdef' => ['ab', 'cd', 'ef']
```

## Square Every Digit
In this kata, you are asked to square every digit of a number and concatenate them.

For example, if we run 9119 through the function, 811181 will come out, because 92 is 81 and 12 is 1.

Note: The function accepts an integer and returns an integer

## Unique in Order
Implement the function unique_in_order which takes as argument a sequence and returns a list of items without any elements with the same value next to each other and preserving the original order of elements.

For example:
```
uniqueInOrder("AAAABBBCCDAABBB") == {'A', 'B', 'C', 'D', 'A', 'B'}
uniqueInOrder("ABBCcAD")         == {'A', 'B', 'C', 'c', 'A', 'D'}
uniqueInOrder([1,2,2,3,3])       == {1,2,3}
```

## Array.diff
Your goal in this kata is to implement a difference function, which subtracts one list from another and returns the result.
It should remove all values from list a, which are present in list b keeping their order.
```
difference [1,2] [1] == [2]
```
If a value is present in b, all of its occurrences must be removed from the other:
```
difference [1,2,2,2,3] [2] == [1,3]
```

## Replace with Alphabet Position
In this kata you are required to, given a string, replace every letter with its position in the alphabet.

If anything in the text isn't a letter, ignore it and don't return it.

`"a" = 1`, `"b" = 2`, etc.
Example
```
alphabet_position("The sunset sets at twelve o' clock.")
```
Should return 
```
"20 8 5 19 21 14 19 5 20 19 5 20 19 1 20 20 23 5 12 22 5 15 3 12 15 3 11"
```
( as a string )

## Beginner Series \#3 Sum of Numbers

Given two integers `a` and `b`, which can be positive or negative, find the sum of all the integers between and including them and return it. If the two numbers are equal return `a` or `b`.

Note: `a` and `b` are not ordered!

**Examples (a, b) --> output (explanation)**

```
(1, 0) --> 1 (1 + 0 = 1)
(1, 2) --> 3 (1 + 2 = 3)
(0, 1) --> 1 (0 + 1 = 1)
(1, 1) --> 1 (1 since both are same)
(-1, 0) --> -1 (-1 + 0 = -1)
(-1, 2) --> 2 (-1 + 0 + 1 + 2 = 2)
```

