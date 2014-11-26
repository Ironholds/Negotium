set hive.mapred.mode = nonstrict;
DROP TABLE ironholds.negotium_uuids;
CREATE TABLE ironholds.negotium_uuids(uuid STRING);
INSERT OVERWRITE TABLE ironholds.negotium_uuids
SELECT uuid FROM (
SELECT DISTINCT(parse_url(concat('http://bla.org/woo/', uri_query), 'QUERY', 'appInstallID')) AS uuid
FROM wmf_raw.webrequest
WHERE uri_query LIKE('%sections=0%')
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
ON parse_url(concat('http://bla.org/woo/', alias1.uri_query), 'QUERY', 'appInstallID') = alias2.uuid
AND uri_query LIKE('%sections=0%')
AND uri_query LIKE('%action=mobileview%')
AND uri_query LIKE('%appInstallID%')
AND webrequest_source IN ('mobile','text')
AND user_agent LIKE('WikipediaApp%')
AND http_status = '200';