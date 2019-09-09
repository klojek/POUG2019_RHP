--IMAGE LIST
select jt.imageid,jt.uri
from json_table(rest_demo('https://exa01vm02:8894/rhp-restapi/rhp/images'),'$.items[*]'
       error on error
       columns (
         imageId varchar2(30) PATH '$.imageId',
         uri varchar2(2000) PATH '$.links.uri'
       )) jt
order by jt.imageid
;

--SHOW IMAGE DETAILS
select col_name,col_val
from json_table(rest_demo('https://exa01vm03:8894/rhp-restapi/rhp/images/12.1.0.2.190416'),'$'
       error on error
       columns (
         homepath varchar2(300) PATH '$.homePath'
         ,imageSize varchar2 PATH '$.imageSize'
         ,owner varchar2(30) PATH '$.owner'
         ,patches varchar2(300) FORMAT JSON PATH '$.patches'
         ,platform varchar2(100) PATH '$.platform'  
         ,groupsConfigured varchar2(200) PATH '$.groupsConfigured'
         ,version varchar2(50) PATH '$.version'
         ,imagestate varchar2(30) PATH '$.imageState'
         ,containsNonRollingPatch varchar2(5) PATH '$.containsNonRollingPatch'
       )) jt
unpivot (col_val for col_name in (homepath,imagesize,owner,patches,platform,groupsconfigured,version,imagestate,containsnonrollingpatch))       
;

--IMAGE DRIFT
select *
from json_table(rest_demo('https://exa01vm03:8894/rhp-restapi/rhp/images/search?drift=true'), '$.items[*]' 
       error on error
       columns (
         imageId varchar2(30) PATH '$.imageId',
         uri varchar2(2000) PATH '$.links.uri'
       )) jt
;

--IMAGE IMPORT
select jt.iserr,DECODE(jt.iserr,'true',err_code||': '||err_msg,jt.uri) output
from json_table(rest_demo('https://exa01vm02:8894/rhp-restapi/rhp/images', v_method => 'POST'
         ,v_text => '{"imageName":"18.190416","path":"/OH_share/18.190416"}'
         ), '$'
         columns (iserr varchar2(5) EXISTS PATH '$.errorCode',
           uri varchar2(300) PATH '$.links.uri',
           err_code varchar2 PATH '$.errorCode',
           err_msg varchar2 PATH '$.title'
         )) jt;           

--IMAGE DELETE
select jt.iserr,DECODE(jt.iserr,'true',err_code||': '||err_msg,jt.uri) output
from json_table(rest_demo('https://exa01vm02:8894/rhp-restapi/rhp/images/18.190416', v_method => 'DELETE'
         ), '$'
         columns (uri varchar2(300) PATH '$.links.uri',
           iserr varchar2(5) EXISTS PATH '$.errorCode',
           err_code varchar2 PATH '$.errorCode',
           err_msg varchar2 PATH '$.title'
         )) jt 
;


