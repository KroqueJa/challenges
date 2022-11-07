module Rot13 where

-- Caesar cipher implementation (specifically to shift 13 steps)

import Data.Char

shift :: Int -> Char -> Char
shift i c
  | c `notElem` ['a'..'z'] && c `notElem` ['A'..'Z'] = c
  | c `elem` ['a'..'z'] = head $ drop i $ dropWhile (/=c) $ cycle ['a'..'z']
  | otherwise = head $ drop i $ dropWhile (/=c) $ cycle ['A'..'Z']

rot13 :: String -> String
rot13 = map (shift 13)
