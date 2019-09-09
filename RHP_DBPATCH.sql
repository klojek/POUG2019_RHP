--DB MOVE/PATCH

  --move DB from unmaged home to managed home
select jt.iserr,DECODE(jt.iserr,'true',err_code||': '||err_msg,jt.uri) output
from json_table(rest_demo('https://exa01vm01:8894/rhp-restapi/rhp/databases', v_method => 'PATCH'
         ,v_text => '{"dbname":"db2cl1","patchedwc":"DB_18_190416","eval":"false","sourceHome":"/u01/app/oracle/product/18.190115/dbhome_1"}'
         ), '$'
         columns (uri varchar2(300) PATH '$.links.uri',
           iserr varchar2(5) EXISTS PATH '$.errorCode',
           err_code varchar2 PATH '$.errorCode',
           err_msg varchar2 PATH '$.title'
         )) jt 
;

  --move DB from managed home to patched managed home
select jt.iserr,DECODE(jt.iserr,'true',err_code||': '||err_msg,jt.uri) output
from json_table(rest_demo('https://exa01vm01:8894/rhp-restapi/rhp/workingcopies/DB_18_190115/databases'
         ,v_method => 'PATCH'
         ,v_text => '{"dbname":"db2cl1","eval":"false","patchedwc":"DB_18_190416"}'
         ), '$'
         columns (uri varchar2(300) PATH '$.links.uri',
           iserr varchar2(5) EXISTS PATH '$.errorCode',
           err_code varchar2 PATH '$.errorCode',
           err_msg varchar2 PATH '$.title'
         )) jt 
;

  --move DB from managed home to new managed home and ignore missing patches
select jt.iserr,DECODE(jt.iserr,'true',err_code||': '||err_msg,jt.uri) output
from json_table(rest_demo('https://exa01vm01:8894/rhp-restapi/rhp/workingcopies/DB_18_190416/databases', v_method => 'PATCH'
         ,v_text => '{"dbname":"db2cl1","eval":"false","patchedwc":"DB_18_190115","ignorewcpatches":"true"}'
         ), '$'
         columns (uri varchar2(300) PATH '$.links.uri',
           iserr varchar2(5) EXISTS PATH '$.errorCode',
           err_code varchar2 PATH '$.errorCode',
           err_msg varchar2 PATH '$.title'
         )) jt 
;


