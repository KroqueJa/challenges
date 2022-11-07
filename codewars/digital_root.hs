module DigitalRoot where

import Control.Monad

digitalRoot :: Integral a => a -> a
digitalRoot x
  | x < 10 = x
  | otherwise = digitalRoot $ sumDigits 0 x
  where 
  sumDigits :: Integral a => a -> a -> a
  sumDigits acc 0 = acc
  sumDigits acc x = sumDigits ((+) acc (mod x 10)) (div x 10)

-- I was pretty happy with this but it pales in comparison to
--
-- digitalRoot 0 = 0
-- digitalRoot n = 1 + (n - 1) `mod` 9
--
-- That's obviously in the category of "mathematical tricks" but it's really cool!
