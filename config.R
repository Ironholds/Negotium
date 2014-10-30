#Libraries
library(WMUtils) #Internal utilities. For great justice and C++!
library(lubridate) #Timestamp handling.
library(digest) #Hashing

#Options
options(scipen = 500, #Scientific notation is silly
        q = "no" #So is saving .RDatas
        )
        
#Config variables
DEFAULT_RUN_LENGTH = 7 #How many days to run over
SAVE_DIR = "/a/aggregate-datasets/readership" #Where to save the results
LOG_DIR = file.path(getwd(),"Logging") #Where to save the run logs