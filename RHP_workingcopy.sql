--LIST HOMES
select jt.workingcopy, jt.uri
from json_table(rest_demo('https://exa01vm03:8894/rhp-restapi/rhp/workingcopies'),'$.items[*]'
       error on error
       columns (
         uri varchar2(300) PATH '$.links.uri',
         workingcopy varchar2(30) PATH '$.workingCopyId')) jt
order by jt.workingcopy
;

--LIST HOME DETAILS
select col_name,col_val
from json_table(rest_demo('https://exa01vm03:8894/rhp-restapi/rhp/workingcopies/DB_12102_190416_p29639963'),'$'
       error on error
       columns (
         imageName varchar2(30) PATH '$.imageName',
         workingCopy varchar2(30) PATH '$.workingCopyId',
         Databases varchar2(2000) FORMAT JSON PATH '$.configuredDatabases',
         groups varchar2(100) FORMAT JSON PATH '$.groupsConfiguredInWorkingCopy',
         ORACLE_HOME varchar2(300) PATH '$.softwareHomePath',
         ORACLE_BASE varchar2(200) PATH '$.oracleBase',
         PATCHES varchar2(2000) PATH '$.allPatchesAvailableInHome',
         PATCHES_NOT_IN_IMAGE varchar2(2000) PATH '$.additionalPatchesComparedToImage'
       )) jt
unpivot (col_val for col_name in (IMAGENAME,workingcopy,databases,groups,oracle_home,oracle_base,patches,PATCHES_NOT_IN_IMAGE))
;

--HOME PROVISIONING
select jt.iserr,DECODE(jt.iserr,'true',err_code||': '||err_msg,jt.uri) output
from json_table(rest_demo('https://exa01vm02:8894/rhp-restapi/rhp/workingcopies', v_method => 'POST'
         ,v_text => '{"oracleBase":"/u01/app/oracle","imageName":"18.190416","workingcopy":"DB_18_190416","user":"oracle"}'
         ), '$'
         columns (uri varchar2(300) PATH '$.links.uri',
           iserr varchar2(5) EXISTS PATH '$.errorCode',
           err_code varchar2 PATH '$.errorCode',
           err_msg varchar2 PATH '$.title'
         )) jt 
;

--SEARCH WORKINGCOPY
select * 
from json_table(rest_demo('https://exa01vm03:8894/rhp-restapi/rhp/workingcopies/search?image=12.1.0.2.190416'),'$.items[*]'
       error on error
       columns (
         workingcopy varchar2(30) PATH '$.workingCopyId',
         uri varchar2(300) PATH '$.links.uri')) jt
order by jt.workingcopy
;


