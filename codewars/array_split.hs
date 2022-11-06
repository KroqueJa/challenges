module Difference where

--Your goal in this kata is to implement a difference function, which subtracts one list from another and returns the result.
--It should remove all values from list a, which are present in list b keeping their order.
--difference [1,2] [1] == [2]
--If a value is present in b, all of its occurrences must be removed from the other:
--difference [1,2,2,2,3] [2] == [1,3]

difference :: Eq a => [a] -> [a] -> [a]
difference a b = filter (`notElem` b) a
