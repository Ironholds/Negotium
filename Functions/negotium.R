negotium <- function(query, type){
  
  #Construct query
  
  #Grab data
  data <- data_retrieve(query)
    
  #Split
  data <- keysplit(obj = data, key_col = "uuid")
  
  #Generate session results
  results <- unlist(parlapply(X = data, #Fork each subset to a different processor
                       FUN = function(x){
                         
                         #Split again and lapply
                         interim_results <- lapply(X = keysplit(obj = x, key_col = "uuid", pieces = length(unique(x$uuid))),
                                                   FUN = result_generator)
                         
                         return(interim_results)
                         
                       }), recursive = FALSE)
  
  #Write
  result_writer(results, type)
  
  #Log
  log_writer(type)
  
  #Return
  return(TRUE)
}