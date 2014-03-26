import Data.Time.Clock
import Data.Time.Calendar
import Data.Time.Format
import Data.String.Utils
import System.Locale
import System.Environment
import Text.CSV
import System.Console.GetOpt

-- ====Args====
data Opts = Opt
    { optYear    :: Integer
    , optMonth   :: Int
    , optOutput  :: String
    , optFR      :: Bool
    , optHelp    :: Bool
    }

data DefOpts = Opt
    { optYear = 2014
    , optMonth = 03
    , optFR = False
    , optHelp = False
    }

options :: [OptDescr (Opts -> IO Opts)]
options =
    [ Option ['y'] ["year"] 
        (ReqArg 
            (\arg opt -> return opt { optYear =  read arg :: Integer })
            "YEAR") 
        "Specify year, or current year by default"

    , Option ['m'] ["month"] 
        (ReqArg
            (\arg opt -> return opt { optMonth = read arg :: Int })
            "MONTH")
        "Specify month, or current month by default"

    , Option ['o'] ["output"] 
        (ReqArg 
            (\arg opt -> return opt { optOutput = arg })
            "FILENAME") 
        "Output result in file"

    , Option []    ["fr"]
        (NoArg
            (\opt -> return opt { optFR = True })
        )
        "Use French words"

    , Option []    ["help"] 
        (NoArg 
            (\opt -> return opt { optHelp = True })
        )
        "Print this help message"
    ]

-- ====Dates====
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

-- ====Main====
main = do
    args <- getArgs
    case getOpt Permute options args of
        (args, _, []) -> do
            putStrLn "It works!"
        (_, _, errs) -> do
            putStrLn "Arg Error"
    (year, month, _) <- currentDate
    let days = daysOfMonth (fromIntegral year) month
    let daysFormatted = formatDays days  
    let csv = getCSV daysFormatted
    putStrLn $ printCSV csv 
