module Difference where

difference :: Eq a => [a] -> [a] -> [a]
difference a b = filter (`notElem` b) a
