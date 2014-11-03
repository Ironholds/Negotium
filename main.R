#Load dependencies
source("config.R")
ignore <- lapply(list.files(file.path(getwd(),"Functions"), full.names = TRUE), source)
#Run
main <- function(){
  
  #Construct query
  query <- query_constructor()
  
  #Grab data
  data <- hive_query(query = query)
  
  #Convert timestamps
  data$timestamp <- as.numeric(log_strptime(data$timestamp))
  data <- data[!is.na(data$timestamp),]
  
  #Generate accurate average intertime
  intertime_list <- unlist(lapply(keysplit(obj = data, key_col = "uuid", pieces = length(unique(data$uuid))),
                                  function(x){return(intertimes(x$timestamp))}))
  intertime_list <- intertime_list[!is.na(intertime_list)]
  avg_intertime <- exp(sum(log(intertime_list[intertime_list > 0]), na.rm = TRUE) / length(intertime_list))
  
  #Split
  split_data <- keysplit(obj = data, key_col = "uuid")
  
  #Generate session results
  results <- unlist(parlapply(X = split_data, #Fork each subset to a different processor
                              FUN = session_analyser, inter_avg = avg_intertime), recursive = FALSE)
  
  #Write
  result_writer(results)
  
  #Done
  return(invisible())
}

main()
q()