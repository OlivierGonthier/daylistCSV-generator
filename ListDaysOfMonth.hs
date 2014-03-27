import Data.Time.Clock
import Data.Time.Calendar
import Data.Time.Format
import Data.String.Utils
import System.Locale
import System.Environment
import Text.CSV
import System.Console.GetOpt
import System.Exit
import Control.Monad

-- | Args

data Opts = Opts
    { optYear    :: Integer
    , optMonth   :: Int
    , optOutput  :: Maybe String
    , optFR      :: Bool
    , optHelp    :: Bool
    } deriving Show 

defOpts :: Opts
defOpts = Opts
    { optYear    = 1970
    , optMonth   = 01
    , optOutput  = Nothing
    , optFR      = False
    , optHelp    = False
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
            (\arg opt -> return opt { optOutput = Just arg })
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

-- | Dates and csv functions

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

printResult :: CSV -> Maybe String ->  IO()
printResult csv Nothing = do
    putStrLn $ printCSV csv 
printResult csv (Just file) = do
    writeFile file $ printCSV csv 

-- | Main

main = do
    (currentYear, currentMonth, _) <- currentDate
    let defOpts' = defOpts{ optYear = currentYear, optMonth = currentMonth }
    
    rawArgs <- getArgs
    let (actions, args, errs) = getOpt Permute options rawArgs
    unless (null errs) $ do
        putStrLn $ concat (errs ++ ["Try ListDaysOfMonth --help for more information."])
        exitFailure 
    opts <- foldl (>>=) (return defOpts') actions
    let Opts { optYear = year
             , optMonth = month
             , optOutput = output
             , optFR = frFlag
             , optHelp = helpFlag
             } = opts

    let days = daysOfMonth (fromIntegral year) month
    let daysFormatted = formatDays days  
    let csv = getCSV daysFormatted
    printResult csv output
