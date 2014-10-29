data_retrieve <- function(query){
  
  #Grab data
  data <- hive_query(query = query)
  
  #Convert timestamps
  data$timestamp <- as.numeric(log_strptime(data$timestamp))
  
  #Hash if appropriate
  if("user_agent" %in% names(data)){
    data <- hash(dt = data)
  }
  
  #Return
  return(data)
}