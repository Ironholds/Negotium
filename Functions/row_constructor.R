row_constructor <- function(x, name, dt){
  
  row_quants <- quantile(x, seq(0,1,0.01))
  
  #Construct a row of...
  row <- c(dt,
          name,
          mean(x),
          min(x),
          max(x),
          unname(row_quants[names(row_quants) == "50%"]),
          unname(row_quants[names(row_quants) == "99%"]))
  
  #Return
  return(row)
}