import System.Environment
import System.IO
import Data.List.Split
import Data.List

solve :: [[Int]] -> [Int]
solve = reverse . sort . map sum
parse :: String -> [[Int]]
parse = map (map read) . splitOn [""] . lines

main = do
  args <- getArgs
  file <- openFile (head args) ReadMode
  input <- hGetContents file
  let lst = solve $ parse input

  putStrLn $ show $ head lst
  putStrLn $ show $ sum $ take 3 lst
