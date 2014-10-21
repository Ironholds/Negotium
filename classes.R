desktop_class <- R6Class(classname = "desktop",
                         public = list(
                           data = NA, #actual data store
                           save_file = "", #Where to put the results
                           log_file = "", #Where to put metadata
                           interval = NA #How long to use between runs
                           
                           #What to do when it starts; write the provided interval to self$interval
                           initialize = function(interval){
                             self$interval <- initialise
                             return(invisible())
                           }
                           
                           #The actual, you know, running function
                           run = function(){
                             
                             #Grab the results and write to data
                             self$data <- self$read_data()
                             
                             
                             
                           }
                         ),
                          private = list(
                            
                            #Timestamp formatter, for creating MySQL-acceptable timestamps from
                            #Stored POSIX timestamps. This'll be used by the mobile_web class too.
                            format_query_timestamps = function(timestamps){
                             
                              #We need to pass this through to MediaWiki-like MySQL tables, so parsing is
                              #important
                              timestamps <- gsub(x = timestamps, pattern = "(:| |-)", replacement = "")
                              return(timestamps)
                            },
                           
                            #Timestamp generator for actually working out the boundaries of the MySQL query
                            generate_query_boundaries = function(){
                             
                              #Read in save_file to grab the max timestamp
                              save_results <- read.delim(file = self$save_file, header = TRUE,
                                                         as.is = TRUE)$end_timestamp
                              save_results <- max(as.POSIXlt(save_results))
                             
                              #Increment to get a minimum value,
                              #Then generate a maximum with the assistance of self$interval.
                              #In both cases, pass through ts_handler
                              min_stamp <- save_results + 1
                              day(save_results) <- day(min_stamp) + self$interval
                              timestamps <- ts_handler(c(min_stamp,save_results))
                              
                              #Return
                              return(timestamps)
                           },
                           
                           #Format timestamps returned in read_data. This will be used by the mobile_web class too.
                           format_result_timestamps = function(ts){
                             
                             return(WMUtils::mw_strptime(ts))
                             
                           },
                           
                           #Data reader
                           read_data = function(){
                             
                             #Grab timestamps
                             timestamps <- self$generate_query_boundaries()
                             
                             #Construct query and run it
                             query_results <- mysql_query(paste("SELECT uuid, timestamp
                                                                 FROM NavigationTiming_10076863
                                                                 WHERE event_mobileMode IS NULL
                                                                 AND timestamp BETWEEN",
                                                                 timestamps[1],"AND",timestamps[2]))
                             
                             
                             #Return
                             return(query_results)
                           }
                           
                           ),
                         portable = FALSE)

mobile_class <- R6Class(classname = "mobile_web",
                        inherit = desktop_class,
                        public = list(),
                        private = list(),
                        portable = FALSE)

app_class <- R6Class(classname = "app",
                     inherit = desktop_class,
                     public = list(),
                     private = list(
                       ),
                     portable = FALSE)