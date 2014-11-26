output_constructor <- function(x, name, file, date){
  
  row_quants <- quantile(x, seq(0,1,0.01))
  
  #Construct a row
  row <- c(date,
          name,
          exp(sum(log(x[x > 0]), na.rm = TRUE) / length(x)),
          mean(x),
          min(x),
          max(x),
          unname(row_quants[names(row_quants) == "50%"]),
          unname(row_quants[names(row_quants) == "99%"]))
  
  #Turn into a data.frame
  row <- as.data.frame(t(as.data.frame(row)), stringsAsFactors = FALSE)
  names(rows) <- c("runtime","variable","geometric mean","mean","minimum","maximum","50% quantile","99% quantile")
  
  #Write file
  if(file.exists(file)){
    row <- rbind(read.delim(file, as.is = TRUE, header = TRUE),row)
  }
  write.table(row, file, append = FALSE, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
  return(TRUE)
}