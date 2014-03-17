import Data.Time.Clock
import Data.Time.Calendar
import Data.Time.Format
import Data.String.Utils
import System.Locale
import System.Environment
import Text.CSV

currentDate :: IO (Integer, Int, Int)
currentDate = fmap (toGregorian . utctDay) getCurrentTime
 
daysOfMonth :: Integer -> Int -> [Day]
daysOfMonth year month = map (fromGregorian year month) [1..gregorianMonthLength year month]

formatDays :: [Day] -> [String]
formatDays = map (formatTime defaultTimeLocale "%A %d %B %Y") 

getCSV :: [Field] -> CSV
getCSV [] = []
getCSV (x:xs) = getRecord x:getCSV xs

getRecord :: Field -> Record
getRecord field 
    | startswith "Saturday" field = [field]
    | startswith "Sunday" field = [field]
    | otherwise = [field, "1"]

groupArgs :: [String] -> [[String]]
groupArgs = (map words).(filter ("" /=)).(split "-").unwords

isolateArgWithValues :: [[String]] -> String -> [String] 
isolateArgWithValues args option = head $ filter (\arg -> head arg == option) args

getValues :: [[String]] -> String -> Int -> [String]
getValues args option count = (take count).(drop 1) $ isolateArgWithValues args option

extractValues :: [[String]] -> (String, String)
extractValues args = (head $ getValues args "y" 1, head $ getValues args "m" 1)

main = do
    args <- getArgs
    let groupedArgs = groupArgs args
    let (argYear, argMonth) = extractValues groupedArgs
    print (argYear, argMonth)
    (year, month, _) <- currentDate
    let days = daysOfMonth year month
    let daysFormatted = formatDays days  
    let csv = getCSV daysFormatted
    putStrLn $ printCSV csv 
