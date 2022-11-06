module GetSum where

getSum :: Int -> Int -> Int
getSum a b
  | a == b = a
  | b < a = getSum b a
  | a == 0 = getSum 1 b
  | b == 0 = getSum a (-1)
  | even (a + b) = a + (getSum (a+1) b)
  | otherwise = (a + b) * ( (b - a + 1) `div` 2 )
