-- Bit of a brutish solution; make one pass through the list, gather
-- all numbers into two accumulator lists and check which one has length 1

findOutlier :: [Int] -> Int 
findOutlier = piles [] []
  where
    piles :: [Int] -> [Int] -> [Int] -> Int
    piles odds evens []
      | (length odds) == 1 = head odds
      | otherwise = head evens
    piles odds evens (x:xs)
      | x `mod` 2 /= 0 = piles (x : odds) evens xs
      | otherwise = piles odds (x : evens) xs 

-- once more, the ideal solution is way better:
--
-- import Data.List (partition)
--
-- findOutlier :: [Int] -> Int
-- findOutlier xs =
--     case partition even xs of
--         ([x], _) -> x
--         (_, [x]) -> x
--         otherwise -> error "invalid input"
--
-- I feel like a general lack of knowledge of available tools and functions
-- is hampering me in all but the simplest challenges. Literacy, basically.
