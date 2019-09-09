--RHP JOBS
  --list jobs
set pages 10000
select jt.jobID,jt.uri
from json_table(rest_demo('https://exa01vm01:8894/rhp-restapi/rhp/jobs'),'$.items[*]'
       error on error
       columns (
         jobID number PATH '$.jobId',
         NESTED PATH '$.links' 
           columns (uri varchar2(300) PATH '$.uri')
         )) jt
order by jobid desc;

  --show job details
select jt.jobid,jt.status,jt.operation
from json_table(rest_demo('https://exa01vm01:8894/rhp-restapi/rhp/jobs/73'), '$'
       error on error
       columns (
         jobID number PATH '$.jobId',
         status varchar2(20) PATH '$.status',
         operation varchar2(1000) PATH '$.operation'
       )) jt
;

  --show job output
select jt.output
from json_table(rest_demo('https://exa01vm01:8894/rhp-restapi/rhp/jobs/26/output'), '$'
       error on error
       columns (output clob PATH '$.output'
       )) jt
;

