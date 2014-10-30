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
  
  #Split
  split_data <- keysplit(obj = data, key_col = "uuid")
  
  #Generate session results
  results <- unlist(parlapply(X = split_data, #Fork each subset to a different processor
                              FUN = function(x){
                                
                                #Split again and lapply
                                interim_results <- lapply(X = keysplit(obj = x, key_col = "uuid", pieces = length(unique(x$uuid))),
                                                          FUN = result_generator)
                                
                                return(interim_results)
                                
                              }), recursive = FALSE)
  
  #Write and log
  complete <- result_writer(results, type)
  
  #Done
  return(TRUE)
}

main()
q()