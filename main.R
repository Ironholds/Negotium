#Load dependencies
source("config.R")
ignore <- lapply(list.files(file.path(getwd(),"Functions"), full.names = TRUE), source)

main <- function(){
  
  #Do we launch? Grab the current day, check if it's 31 days after the previous run, stopifnot.
  current_runtime <- Sys.Date()
  if(file.exists(file.path(save_dir,"session_length.tsv"))){
    previous_runtime <- max(as.Date(read.delim(file.path(save_dir,"session_length.tsv"), as.is = TRUE, header = TRUE)$runtime))
    stopifnot((previous_runtime + 31) == current_runtime)
  }
  
  #Grab data
  data <- dep_hive_query("query.hql", skip = 2)
  
  #Convert timestamps
  data$timestamp <- as.numeric(log_strptime(data$timestamp))
  data <- data[!is.na(data$timestamp),]
  
  #Sessionise
  data <- lapply(split(data$timestamp,data$uuid),function(x){return(sessionise(list(x),1800))})
  
  #Sessions by user
  sess_by_user <- unlist(lapply(data,length))
  
  #Pages per session, session length
  data <- unlist(data, recursive = FALSE)
  sess_length <- session_length(data, preserve_single_events = FALSE, padding_value = 0)
  sess_length <- sess_length[sess_length > -1]
  sess_pages <- session_events(data)
  
  #Write
  output_constructor(x = sess_by_user, name = "sessions per user",
                     file = "sessions_per_user.tsv", date = current_runtime)
  output_constructor(x = sess_length, name = "pages per session",
                     file = "pages_per_session.tsv", date = current_runtime)
  output_constructor(x = sess_pages, name = "session length",
                     file = "session_length.tsv", date = current_runtime)
  
  #Done
  return(invisible())
}
main()
q(save = "no")