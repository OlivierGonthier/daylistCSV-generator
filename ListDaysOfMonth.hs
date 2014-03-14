import Data.Time.Clock
import Data.Time.Calendar
import Data.Time.Format
import Data.String.Utils
import System.Locale
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

main = do
    (year, month, _) <- currentDate
    let days = daysOfMonth year month
    let daysFormatted = formatDays days  
    let csv = getCSV daysFormatted
    putStrLn $ printCSV csv 
