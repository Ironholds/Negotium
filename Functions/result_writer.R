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
    write.table(rows, file, append = TRUE, row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")
  } else {
    write.table(rows, file, append = FALSE, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
  }

}