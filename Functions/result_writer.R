result_writer <- function(x){
  
  #Generate dt
  dt <- as.character(Sys.time())
  
  #Extract:
  sessions <- unlist(lapply(x, function(x){return(x$sessions)}))#number of sessions_per_user
  pages <- unlist(lapply(x, function(x){return(x$pages)}))#Number of pages per session
  length <- unlist(lapply(x, function(x){return(x$session_length)}))#Length of sessions
  
  #For each one, compute a row
  rows <- data.frame(rbind(row_constructor(sessions, "sessions per user", dt),
                           row_constructor(pages, "pages per session", dt),
                           row_constructor(length, "session length", dt)),
                           stringsAsFactors = FALSE)
  #Names
  names(rows) <- c("runtime","variable","geometric mean","mean","minimum","maximum","50% quantile","99% quantile")
  
  #Write out
  if(file.exists(SAVE_FILE)){
    rows <- rbind(read.delim(SAVE_FILE, header = TRUE, as.is = TRUE, quote = ""),rows)
  }
  write.table(rows, SAVE_FILE, append = FALSE, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
  
  #Done
  return(invisible())
  
}