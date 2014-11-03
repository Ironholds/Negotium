session_analyser <- function(events, threshold = 3600){
  
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
  
}