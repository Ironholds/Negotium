desktop_class <- R6Class(classname = "desktop",
                         public = list(
                           data = NA, #actual data store
                           save_file = "turnip.tsv", #Where to put the results
                           log_file = "", #Where to put metadata
                           interval = NA, #How long to use between runs
                           
                           #What to do when it starts; write the provided interval to self$interval
                           initialize = function(interval){
                             self$interval <- interval
                             return(invisible())
                           },
                           
                           #The actual, you know, running function
                           run = function(){
                             
                             #Grab the results and hold
                             results <- private$read_data()
                             
                             #Retrieve results
                             
                             
                           }
                         ),
                          private = list(
                            
                            #Timestamp formatter, for creating MySQL-acceptable timestamps from
                            #Stored POSIX timestamps. This'll be used by the mobile_web class too.
                            format_query_timestamps = function(timestamps){
                             
                              #We need to pass this through to MediaWiki-like MySQL tables, so parsing is
                              #important
                              timestamps <- WMUtils::to_mw(timestamps)
                              return(timestamps)
                            },
                           
                            #Timestamp generator for actually working out the boundaries of the MySQL query
                            generate_query_boundaries = function(){
                             
                              #Read in save_file to grab the max timestamp - if it exists
                              if(file.exists(self$save_file)){
                                save_results <- read.delim(file = self$save_file, header = TRUE,
                                                           as.is = TRUE)$end_timestamp
                                start_time <- end_time <- (max(as.POSIXlt(save_results))+1)
                                lubridate::day(end_time) <- (lubridate::day(end_time) + self$interval)
                              
                              } else {
                                
                                #If it doesn't exist...make it up!
                                start_time <- end_time <- Sys.time()
                                lubridate::day(start_time) <- (lubridate::day(start_time) - self$interval)
                                
                              }
                              
                              #Either way, we should have start/end timestamps. Pass them through format_query_timestamps
                              timestamps <- private$format_query_timestamps(c(start_time,end_time))
                              
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
                             timestamps <- private$generate_query_boundaries()
                             
                             #Construct query and run it
                             query_results <- WMUtils::mysql_query(paste("SELECT uuid, timestamp
                                                                   FROM NavigationTiming_10076863
                                                                   WHERE event_mobileMode IS NULL
                                                                   AND timestamp BETWEEN",
                                                                   timestamps[1],"AND",timestamps[2]))
                             
                             #If there are no rows, stop
                             if(nrow(query_results) == 0){
                               
                               private$log_writer(string = "No rows to retrieve",
                                                  start_stamp = timestamps[1],
                                                  end_stamp = timestamps[2])
                               
                             }
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