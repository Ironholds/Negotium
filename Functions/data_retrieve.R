data_retrieve <- function(query){
  
  #Grab data
  data <- hive_query(query = query)
  
  #Convert timestamps
  data$timestamp <- as.numeric(log_strptime(data$timestamp))
  
  #Hash if appropriate
  if("user_agent" %in% names(data)){
    
    #Handle XFFs
    is_xff <- !data$xff == "-"
    data$ip[is_xff] <- data$xff[is_xff]
    
    #Create output object
    hashes <- character(nrow(data))
    
    #Hash
    for(i in seq_along(hashes)){
      
      hashes[i] <- digest(object = paste(data$ip[i],data$user_agent[i],data$lang_code[i]))
      
    }
    
    #Add hashes to dt
    data$uuid <- hashes
    
    #Null out columns we no longer care for and return
    data <- data[,c("ip","xff","user_agent","lang_code") := NULL]
    
  }
  
  #Return
  return(data)
}