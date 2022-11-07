module MultiplesOf3And5 where

-- Golfed into nigh-unreadability for point free karma

import Control.Monad

isDivisor :: Integer -> Integer -> Bool
isDivisor = ((==0) .) . flip mod

solution :: Integer -> Integer
solution = sum . filter (liftM2 (||) (isDivisor 3) (isDivisor 5)) . (flip take)  [1, 2..] . fromIntegral . (flip (-)) 1
