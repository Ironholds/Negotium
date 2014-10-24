desktop_class <- R6Class(classname = "desktop",
                         public = list(
                           data = NA, #actual data store
                           class = "desktop", #Class
                           results_file = "desktop_results.tsv", #Where to put the results
                           log_file = "desktop_log.tsv", #Where to put metadata
                           interval = NA, #How long to use between runs
                           timestamps = NA, #Timestamp element storage
                           results = NA, #The results
                           
                           #What to do when it starts; write the provided interval to self$interval
                           initialize = function(interval){
                             self$interval <- interval
                             return(invisible())
                           },
                           
                           #The actual, you know, running function
                           run = function(){
                             
                             #Grab the results and hold
                             self$data <- private$read_data()
                             results <- self$data
                             #Convert timestamps
                             results$timestamp <- as.numeric(WMUtils::log_strptime(results$dt))
                             
                             #Handle IPs
                             is_xff <- !results$x_forwarded_for == "-"
                             results$ip[is_xff] <- results$xff[is_xff]
                             
                             #Generate hashes
                             results$uuid <- private$hash_gen(results)
                             
                             #Strip columns we don't care about.
                             results <- results[,c("dt", "ip", "x_forwarded_for", "user_agent", "accept_language") := NULL]
                             
                             #Stick in public$data, return TRUE
                             self$data <- results
                             return(TRUE)
                             
                           }
                         ),
                          private = list(
                            
                            #Timestamp generator for actually working out the boundaries of the MySQL query
                            generate_query_boundaries = function(){
                             
                              #Read in save_file to grab the max timestamp - if it exists
                              if(file.exists(self$results_file)){
                                save_results <- read.delim(file = file.path(getwd(),"Results",self$results_file),
                                                           header = TRUE, as.is = TRUE)$end_timestamp
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
                            
                            #Hash generator
                            hash_gen = function(x){
                              
                              #Create output vector
                              output <- character(nrow(x))
                              
                              #Loop
                              for(i in seq_along(output)){
                                
                                output[i] <- digest(paste0(x$ip[i],x$user_agent[i],x$accept_language[i]), algo = "sha256")
                                
                              }
                              
                              #Done!
                              return(output)
                            },
                            
                            #Data reader
                            read_data = function(){
                             
                             #Generate timestamps. If that fails, stop
                             if(!private$generate_query_boundaries()){
                               
                               private$log_writer(string = "timestamps could not be generated", success = FALSE)
                               stop("timestamps could not be generated")
                               
                             }
                                                          
                             #Construct query and run it
                             query_results <- private$query()
                             
                             #If there are no rows, stop
                             if(nrow(query_results) == 0){
                               
                               private$log_writer(string = "No rows to retrieve", success = FALSE)
                               stop("no rows to retrieve")
                               
                             }
                             
                             #Return
                             return(query_results)
                           },
                            
                            #Query generator/runner
                            query = function(){
                              
                              #Work out date range
                              query_range <- WMUtils::hive_range(self$timestamps[1],self$timestamps[2])
                              
                              #Run query
                              return(hive_query(
                                query = paste("set hive.mapred.mode = nonstrict;
                                               DROP TABLE ironholds.desktop_session_ips;
                                               CREATE TABLE ironholds.desktop_session_ips(ip STRING);
                                               INSERT OVERWRITE TABLE ironholds.desktop_session_ips
                                               SELECT * FROM (
                                                SELECT DISTINCT(ip) AS ip FROM wmf_raw.webrequest",query_range,
                                                "AND webrequest_source = 'text'
                                                ORDER BY rand()) sub1
                                               LIMIT 100000;
                                               SELECT dt, alias1.ip, x_forwarded_for, user_agent, accept_language
                                                FROM wmf_raw.webrequest alias1 INNER JOIN ironholds.desktop_session_ips alias2
                                                ON alias1.ip = alias2.ip",
                                                  query_range, "AND webrequest_source = 'text'
                                                  AND content_type LIKE('text/html%');")))
                            },
                           
                           log_writer = function(string, success){
                             
                             #Generate log line
                             log_line <- c(Sys.time(),
                                           success,
                                           string,
                                           self$timestamp[1],
                                           self$timestamp[2])
                             
                             #Does the log file exist?
                             if(file.exists(self$log_file)){
                               
                               #If so, append
                               write.table(t(log_line), file = self$log_file,
                                           append = TRUE, quote = TRUE, sep = "\t",
                                           row.names = FALSE)
                             } else {
                               
                               #If not, create and append.
                               dir.create(file.path(getwd(),"logging"), showWarnings = FALSE)
                               write.table(t(log_line), file = self$log_file,
                                           append = FALSE, quote = TRUE, sep = "\t",
                                           row.names = FALSE)
                             }
                             
                             #Either way, return invisibly
                             return(invisible())
                           },
                           
                           result_writer = function(){
                             
                             
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