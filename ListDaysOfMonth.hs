import Data.Time.Clock
import Data.Time.Calendar
import Data.Time.Format
import System.Locale

currentDate :: IO (Integer, Int, Int)
currentDate = fmap (toGregorian . utctDay) getCurrentTime
 
daysOfMonth :: Integer -> Int -> [Day]
daysOfMonth year month = map (fromGregorian year month) [1..gregorianMonthLength year month]
 
main = do
    (year, month, _) <- currentDate
    let days = daysOfMonth year month
    let daysString = map (formatTime defaultTimeLocale "%A %d %B %Y") days  
    mapM_ print daysString
