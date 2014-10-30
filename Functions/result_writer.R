result_writer <- function(x, type){
  
  #Generate dt
  dt <- as.character(Sys.time())
  
  #Extract:
  sessions <- unlist(lapply(x, function(x){return(length(x$sessions))}))#number of sessions_per_user
  pages <- unlist(lapply(x, function(x){return(x$pages)}))#Number of pages per session
  length <- unlist(lapply(x, function(x){return(x$session_length)}))#Length of sessions
  
  #For each one, compute a row
  rows <- data.frame(rbind(row_constructor(sessions, "sessions per user", dt),
                           row_constructor(pages, "pages per session", dt),
                           row_constructor(length, "session length", dt)),
                           stringsAsFactors = FALSE)
  
  #Names
  names(rows) <- c("runtime","variable","mean","minimum","maximum","50% quantile","99% quantile")
  
  #Write out
  file <- file.path(SAVE_DIR, paste0(type,"_session_analysis_results.tsv"))
  if(file.exists(file)){
    data <- rbind(read.delim(file, header = TRUE, as.is = TRUE, quote = ""),rows)
  }
  write.table(data, file, append = FALSE, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
  
  #Log
  log_line <- data.frame(runtime = dt, type = type, stringsAsFactors = FALSE)
  if(file.exists(LOG_FILE)){
    data <- rbind(read.delim(LOG_FILE),log_line)
  }
  write.table(data, LOG_FILE, append = FALSE, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
  
  #Return
  return(TRUE)
  
}