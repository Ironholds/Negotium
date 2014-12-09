#Libraries
library(WMUtils) #Internal utilities. For great justice and C++!
library(reconstructr)
library(lubridate) #Timestamp handling.
library(parallel) #Parallelisation

#Options
options(scipen = 500, #Scientific notation is silly
        q = "no")#So is saving .RDatas
        
save_dir = "/a/aggregate-datasets/apps/" #Where to save the results