session_analyser <- function(split_list, inter_avg = 430){
  
  #Split again and lapply
  interim_results <- lapply(X = keysplit(obj = split_list, key_col = "uuid", pieces = length(unique(split_list$uuid))),
                            FUN = function(events, inter_avg){
                              
                              #If there's only one event, this is easy - just return with the default
                              if(nrow(events) == 1){
                                
                                return(list(pages = 1,
                                            sessions = 1,
                                            session_length = inter_avg)
                                )
                                
                              }
                              
                              #Otherwise, compute intertimes
                              intertime_vals <- intertimes(timestamps = events$timestamp)
                              
                              #And then generate, in sequence, and return...
                              return(list(pages = session_pages(intertimes = intertime_vals), #Number of pages in the session(s)
                                          sessions = session_count(x = intertime_vals), #Number of sessions in the series of events
                                          session_length = session_length(intertimes = intertime_vals,
                                                                          average_intertime = inter_avg) #Length of the session(s)
                              )
                              )
                              
                            }, inter_avg = inter_avg)
  
  #Return
  return(interim_results)
  
}