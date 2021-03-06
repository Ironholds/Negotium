output_constructor <- function(x, name, file, date){
  
  row_quants <- quantile(x, seq(0,1,0.01))
  
  #Construct a row
  row <- c(as.character(date),
          name,
          exp(sum(log(x[x > 0]), na.rm = TRUE) / length(x)),
          mean(x),
          min(x),
          unname(row_quants[names(row_quants) == "25%"]),
          unname(row_quants[names(row_quants) == "50%"]),
          unname(row_quants[names(row_quants) == "75%"]),
          unname(row_quants[names(row_quants) == "99%"]),
          max(x))
  
  #Turn into a data.frame
  row <- as.data.frame(t(as.data.frame(row)), stringsAsFactors = FALSE)
  names(row) <- c("runtime","variable","geometric mean","mean","minimum","25% quantile","50% quantile",
                  "75% quantile","99% quantile","maximum")
  
  #Write file
  if(file.exists(file.path(save_dir,file))){
    row <- rbind(read.delim(file, as.is = TRUE, header = TRUE),row)
  }
  write.table(row, file.path(save_dir,file), append = FALSE, row.names = FALSE,
              col.names = TRUE, quote = FALSE, sep = "\t")
  return(TRUE)
}