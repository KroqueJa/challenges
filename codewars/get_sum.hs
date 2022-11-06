module GetSum where

--Given two integers `a` and `b`, which can be positive or negative, find the sum of all the integers between and including them and return it. If the two numbers are equal return `a` or `b`.
--Note: `a` and `b` are not ordered!
--Examples (a, b) --> output (explanation)
--(1, 0) --> 1 (1 + 0 = 1)
--(1, 2) --> 3 (1 + 2 = 3)
--(0, 1) --> 1 (0 + 1 = 1)
--(1, 1) --> 1 (1 since both are same)
--(-1, 0) --> -1 (-1 + 0 = -1)
--(-1, 2) --> 2 (-1 + 0 + 1 + 2 = 2)

getSum :: Int -> Int -> Int
getSum a b
  | a == b = a
  | b < a = getSum b a
  | a == 0 = getSum 1 b
  | b == 0 = getSum a (-1)
  | even (a + b) = a + (getSum (a+1) b)
  | otherwise = (a + b) * ( (b - a + 1) `div` 2 )
