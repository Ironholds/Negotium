desktop_class <- R6Class(classname = "desktop",
                         public = list(
                           data = NA, #actual data store
                           save_file = "turnip.tsv", #Where to put the results
                           log_file = "", #Where to put metadata
                           interval = NA, #How long to use between runs
                           timestamps = NA, #Timestamp element storage
                           
                           #What to do when it starts; write the provided interval to self$interval
                           initialize = function(interval){
                             self$interval <- interval
                             return(invisible())
                           },
                           
                           #The actual, you know, running function
                           run = function(){
                             
                             #Grab the results and hold
                             results <- private$read_data()
                             
                             #Convert timestamps
                             results$timestamp <- as.character(WMUtils::log_strptime(results$timestamp))
                             
                             #Stick in public$data, return TRUE
                             self$data <- results
                             return(TRUE)
                             
                           }
                         ),
                          private = list(
                           
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
                              
                              #Store and return
                              self$timestamps <- c(start_time,end_time)
                              return(TRUE)
                           },
                           
                            #Data reader
                            read_data = function(){
                             
                             #Generate timestamps. If that fails, stop
                             if(!private$generate_query_boundaries()){
                               
                               private$log_writer(string = "timestamps could not be generated",
                                                  start_stamp = self$timestamps[1],
                                                  end_stamp = self$timestamps[2])
                               stop("timestamps could not be generated")
                               
                             }
                                                          
                             #Construct query and run it
                             query_results <- private$query()
                             
                             #If there are no rows, stop
                             if(nrow(query_results) == 0){
                               
                               private$log_writer(string = "No rows to retrieve",
                                                  start_stamp = self$timestamps[1],
                                                  end_stamp = self$timestamps[2])
                               
                               stop("no rows to retrieve")
                               
                             }
                             
                             #Return
                             return(query_results)
                           },
                            
                            #Query generator/runner
                            query = function(){
                              
                              return(hive_query(
                                query = paste("set hive.mapred.mode = nonstrict;
                                               DROP TABLE ironholds.desktop_session_ips;
                                               CREATE TABLE ironholds.desktop_session_ips(ip STRING);
                                               INSERT OVERWRITE TABLE ironholds.desktop_session_ips
                                               SELECT ip FROM (
                                                SELECT DISTINCT(ip) AS ip",WMUtils::hive_range(self$timestamps[1],self$timestamps[2]),
                                                "AND webrequest_source = 'text'
                                                ORDER BY rand()) sub1
                                               LIMIT 100000;")))
                                                
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