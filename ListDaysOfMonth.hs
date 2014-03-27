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

frenchTimeLocale :: TimeLocale 
frenchTimeLocale =  TimeLocale { 
        wDays  = [("Dimanche",   "Dim"),  ("Lundi",    "Lun"),   
                  ("Mardi",  "Mar"),  ("Mercredi", "Mer"), 
                  ("Jeudi", "Jeu"),  ("Vendredi",    "Ven"), 
                  ("Samedi", "Sam")],

        months = [("Janvier",   "Jan"), ("Février",  "Fev"),
                  ("Mars",     "Mar"), ("Avril",     "Avr"),
                  ("Mai",       "Mai"), ("Juin",      "Juin"),
                  ("Juillet",      "Juil"), ("Août",    "Aou"),
                  ("Septembre", "Sep"), ("Octobre",   "Oct"),
                  ("Novembre",  "Nov"), ("Décembre",  "Dec")],

        intervals = [ ("année","années")
                    , ("mois", "mois")
                    , ("jour","jours")
                    , ("heure","heures")
                    , ("min","mins")
                    , ("sec","secs")
                    , ("usec","usecs")
                    ],

        amPm = ("AM", "PM"),
        dateTimeFmt = "%A %e %B %Y %H:%M:%S %Z",
        dateFmt = "%d/%m/%y",
        timeFmt = "%H:%M:%S",
        time12Fmt = "%I:%M:%S %p"
        }


currentDate :: IO (Integer, Int, Int)
currentDate = fmap (toGregorian . utctDay) getCurrentTime
 
daysOfMonth :: Integer -> Int -> [Day]
daysOfMonth year month = map (fromGregorian year month) [1..gregorianMonthLength year month]

formatDays :: TimeLocale -> [Day] -> [String]
formatDays timeLocale = map (formatTime timeLocale "%A %d %B %Y") 

getCSV :: [Field] -> CSV
getCSV [] = []
getCSV (x:xs) = getRecord x:getCSV xs

getRecord :: Field -> Record
getRecord field 
    | startswith "Saturday" field = [field]
    | startswith "Sunday" field = [field]
    | startswith "Samedi" field = [field]
    | startswith "Dimanche" field = [field]
    | otherwise = [field, "1"]

printResult :: CSV -> Maybe String ->  IO()
printResult csv Nothing = do
    putStrLn $ printCSV csv 
printResult csv (Just file) = do
    writeFile file $ printCSV csv 
    putStrLn $ "File \"" ++ file ++ "\" has been written."

-- | Main

main = do
    (currentYear, currentMonth, _) <- currentDate
    let defOpts' = defOpts{ optYear = currentYear, optMonth = currentMonth }
    
    rawArgs <- getArgs
    let (actions, args, errs) = getOpt Permute options rawArgs

    unless (null errs) $ do
        putStrLn $ concat errs ++ usageInfo "" options
        exitFailure
 
    opts <- foldl (>>=) (return defOpts') actions
    let Opts { optYear = year
             , optMonth = month
             , optOutput = output
             , optFR = frFlag
             , optHelp = helpFlag
             } = opts

    when helpFlag $ do
        putStrLn $ usageInfo "" options
        exitSuccess

    let timeLocale = if frFlag 
        then frenchTimeLocale
        else defaultTimeLocale

    let days = daysOfMonth (fromIntegral year) month
    let daysFormatted = formatDays timeLocale days  
    let csv = getCSV daysFormatted
    printResult csv output
