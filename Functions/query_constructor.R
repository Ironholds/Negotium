query_constructor <- function(){
  
  #Note current time
  cur_time <- Sys.time()
  
  #Grab file, if it exists.
  if(file.exists(SAVE_FILE)){
    last_run <- max(as.POSIXlt(read.delim(SAVE_FILE, headers = TRUE, as.is = TRUE)$runtime))
  } else {
    last_run <- cur_time
    day(last_run) <- day(last_run)-DEFAULT_RUN_LENGTH
  }
  
  #Construct query
  query <- paste("set hive.mapred.mode = nonstrict;
  DROP TABLE ironholds.negotium_uuids;
  CREATE TABLE ironholds.negotium_uuids(uuid STRING);
  INSERT OVERWRITE TABLE ironholds.negotium_uuids
  SELECT uuid FROM (
    SELECT DISTINCT(parse_url(concat('http://bla.org/woo/', uri_query), 'QUERY', 'appInstallID')) AS uuid 
    FROM wmf_raw.webrequest",hive_range(last_run,cur_time),
    "AND uri_query LIKE('%sections=0%')
    AND uri_query LIKE('%action=mobileview%')
    AND uri_query LIKE('%appInstallID%')
    AND webrequest_source IN ('mobile','text')
    AND user_agent LIKE('WikipediaApp%')
    AND http_status = '200'
    ORDER BY rand()) sub1
  LIMIT 100000;
  SELECT alias1.dt AS timestamp,
  parse_url(concat('http://bla.org/woo/', alias1.uri_query), 'QUERY', 'appInstallID') AS uuid
  FROM wmf_raw.webrequest alias1 INNER JOIN ironholds.negotium_uuids alias2
  ON parse_url(concat('http://bla.org/woo/', alias1.uri_query), 'QUERY', 'appInstallID') = alias2.uuid",
    hive_range(last_run, cur_time),"
  AND uri_query LIKE('%sections=0%')
  AND uri_query LIKE('%action=mobileview%')
  AND uri_query LIKE('%appInstallID%')
  AND webrequest_source IN ('mobile','text')
  AND user_agent LIKE('WikipediaApp%')
  AND http_status = '200';")
  
  #Return query
  return(query)
}