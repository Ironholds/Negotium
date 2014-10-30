#Load dependencies
source("config.R")

#Run
main <- function(){
  
  #Construct query
  query <- query_constructor()
  
  #Grab data
  data <- hive_query(query = query)
  
  #Convert timestamps
  data$timestamp <- as.numeric(log_strptime(data$timestamp))
  data <- data[!is.na(data),]
  
  #Split
  split_data <- keysplit(obj = data, key_col = "uuid")
  
  #Generate session results
  results <- unlist(parlapply(X = split_data, #Fork each subset to a different processor
                              FUN = function(x){
                                
                                #Split again and lapply
                                interim_results <- lapply(X = keysplit(obj = x, key_col = "uuid", pieces = length(unique(x$uuid))),
                                                          FUN = function(events){
                                                            
                                                            #If there's only one event, this is easy - just return with the default
                                                            if(nrow(events) == 1){
                                                              
                                                              return(list(pages = 1,
                                                                          sessions = 1,
                                                                          session_length = 430)
                                                              )
                                                              
                                                            }
                                                            
                                                            #Otherwise, compute intertimes
                                                            intertime_vals <- intertimes(timestamps = events$timestamp)
                                                            
                                                            #And then generate, in sequence, and return...
                                                            return(list(pages = session_pages(intertime_vals), #Number of pages in the session(s)
                                                                        sessions = session_count(intertime_vals), #Number of sessions in the series of events
                                                                        session_length = session_length(intertime_vals) #Length of the session(s)
                                                            )
                                                            )
                                                            
                                                          })
                                
                                return(interim_results)
                                
                              }), recursive = FALSE)
  
  #Write and log
  complete <- result_writer(results, type)
  
  #Done
  return(TRUE)
}

main()
q()