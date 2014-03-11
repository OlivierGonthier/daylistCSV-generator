import Data.Time.Clock
import Data.Time.Calendar

currentDate :: IO (Integer, Int, Int)
currentDate = fmap (toGregorian . utctDay) getCurrentTime

daysOfMonth :: Integer -> Int -> [Day]
daysOfMonth year month = map (fromGregorian year month) [1..gregorianMonthLength year month]

main = do
    (year, month, _) <- currentDate
    let days = daysOfMonth year month
    putStrLn $ "Days: " ++ (show $ length days)
    mapM_ print days