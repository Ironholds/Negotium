#Generates a unique-ish hash from IP, user_agent, accept_language
hash <- function(dt){
  
  #Handle XFFs
  is_xff <- !dt$x_forwarded_for == "-"
  dt$ip[is_xff] <- dt$x_forwarded_for[is_xff]
  
  #Create output object
  hashes <- character(nrow(dt))
  
  #Hash
  for(i in seq_along(hashes)){
    
    hashes[i] <- digest(object = paste(dt$ip[i],dt$user_agent[i],dt$accept_language[i]))
    
  }
  
  #Add hashes to dt
  dt$uuid <- hashes
  
  #Null out columns we no longer care for and return
  dt <- dt[,c("ip","x_forwarded_for","user_agent","accept_language") := NULL]
  return(dt)
}