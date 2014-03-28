daylistCSV-generator
====================

A haskell script to generate a csv file with day list of a given month, for timesheets.

I know that easier solutions exist to create timesheets, this was only a excuse to practice some haskell.  
I'm new with Haskell so feel free to correct me if the code doesn't seems good enough to your expert eyes! (I would owe you a beer)

**Install and run**

        cabal install csv
        ghc daylistCSV-generator.hs
        daylistCSV-generator --help
        
**Result example**

        "Saturday 01 March 2014"
        "Sunday 02 March 2014"
        "Monday 03 March 2014","1"
        "Tuesday 04 March 2014","1"
        "Wednesday 05 March 2014","1"
        "Thursday 06 March 2014","1"
        "Friday 07 March 2014","1"
        "Saturday 08 March 2014"
        "Sunday 09 March 2014"
        "Monday 10 March 2014","1"
        "Tuesday 11 March 2014","1"
        "Wednesday 12 March 2014","1"
        "Thursday 13 March 2014","1"
        "Friday 14 March 2014","1"
        "Saturday 15 March 2014"
        "Sunday 16 March 2014"
        "Monday 17 March 2014","1"
        "Tuesday 18 March 2014","1"
        "Wednesday 19 March 2014","1"
        "Thursday 20 March 2014","1"
        "Friday 21 March 2014","1"
        "Saturday 22 March 2014"
        "Sunday 23 March 2014"
        "Monday 24 March 2014","1"
        "Tuesday 25 March 2014","1"
        "Wednesday 26 March 2014","1"
        "Thursday 27 March 2014","1"
        "Friday 28 March 2014","1"
        "Saturday 29 March 2014"
        "Sunday 30 March 2014"
        "Monday 31 March 2014","1"

**Options**

          -y YEAR      --year=YEAR        Specify year, or current year by default
          -m MONTH     --month=MONTH      Specify month, or current month by default
          -o FILENAME  --output=FILENAME  Output result in file
                       --fr               Use French words
                       --help             Print this help message

