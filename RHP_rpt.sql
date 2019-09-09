desc users.rhpservers
Name         Null? Type         
------------ ----- ------------ 
CLUSTER_NAME       VARCHAR2(30) 
IP                 VARCHAR2(15) 
ENABLED            NUMBER(1)    


select ip, enabled from users.rhp_servers;
IP		ENABLED
--------------- -------
exa01vm03	1
exa01vm02	1
exa01vm01	1


--SELECT ALL IMAGES 
SELECT cluster_name,image
FROM rhp_rpt.list_images(CURSOR(SELECT /*+ PARALLEL(rs,3) */ * FROM users.rhp_servers rs where enabled=1))
order by 1,2
;

--SELECT ALL DRIFTED IMAGES
SELECT cluster_name,image
FROM rhp_rpt.list_image_drift(CURSOR(SELECT /*+ PARALLEL(rs,3) */ * FROM users.rhp_servers rs where enabled=1))
order by 1,2
;

--SELECT ALL HOMES
SELECT cluster_name,workingcopy
FROM rhp_rpt.list_homes(CURSOR(SELECT /*+ PARALLEL(rs,3) */ * FROM users.rhp_servers rs where enabled=1))
order by 1,2
;

--SELECT ORACLE HOMES DETAILS 
SELECT cluster_name,imagename,workingcopy,databases,groups,oracle_home,oracle_base,patches,patches_not_in_image
FROM rhp_rpt.list_homes_details(CURSOR(SELECT cluster_name,workingcopy 
                                       FROM rhp_rpt.list_homes(CURSOR(SELECT /*+ PARALLEL(rs,3) */ * FROM users.rhp_servers rs where enabled=1))
                                       WHERE workingcopy = 'DB_18_190416'))
order by 1,2,3
;





















create table aaa (srv varchar2(20),username varchar2(10),OH varchar2(100));
select * from aaa;
select distinct srv from aaa order by 1;
select distinct username from aaa;
select distinct OH from aaa order by 1;
select username,OH,count(*) from aaa group by username,OH;

--select 
select distinct username dbusers from aaa;
select srv,count(distinct OH2) Ohomes from aaa group by srv order by 2; 
select sum(ohomes) from (select count(distinct OH2) Ohomes from aaa group by srv ); 
select count(*) from aaa;

update aaa set oh2=username||'/'||oh;




select * from aaa;
truncate table aaa;
