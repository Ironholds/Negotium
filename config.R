#Libraries
library(WMUtils) #Internal utilities. For great justice and C++!
library(lubridate) #Timestamp handling.

#Options
options(scipen = 500, #Scientific notation is silly
        q = "no" #So is saving .RDatas
        )
        
#Config variables
DEFAULT_RUN_LENGTH = 7 #How many days to run over
SAVE_FILE = "/a/aggregate-datasets/session_data.tsv" #Where to save the results
LOG_FILE = file.path(getwd(),"Logging","logging.tsv") #Where to save the run logs