module OnesAndZeroes (toNumber) where

--Given an array of ones and zeroes, convert the equivalent binary value to an integer.
--Eg: [0, 0, 0, 1] is treated as 0001 which is the binary representation of 1.

-- Note: this function uses little endian, so it must be fed the list in reverse order from the problem description
toNumRecur :: Int -> Int -> [Int] -> Int
toNumRecur _ sum [] = sum
toNumRecur pow sum (x:xs) = toNumRecur (pow*2) (sum+pow*x) xs

toNumber :: [Int] -> Int
toNumber = (toNumRecur 1 0) . reverse
