CREATE OR REPLACE PACKAGE RHP_rpt AS
  TYPE t_rhp_servers_rt IS RECORD (cluster_name varchar2(20),IP VARCHAR2(50),ENABLED NUMBER(1));
  TYPE t_rhp_servers_tt IS TABLE OF t_rhp_servers_rt;
  TYPE t_rhp_servers_ref_cursor IS REF CURSOR RETURN users.rhp_servers%ROWTYPE; 
  type wc_rt is record (cluster_name varchar2(20), workingcopy varchar2(50),sid_serial varchar2(20));
  type wc_tt is table of wc_rt;
  type img_rt is record (cluster_name varchar2(20), image varchar2(50),sid_serial varchar2(20));
  type img_tt is table of img_rt;

  TYPE wc_details_ref_cursor IS REF CURSOR RETURN wc_det%ROWTYPE; 
  type wc_details_rt is record (cluster_name varchar2(20),IMAGENAME varchar2(30),workingcopy varchar2(100),databases varchar2(2000),groups varchar2(100),oracle_home varchar2(300),oracle_base varchar2(200),patches varchar2(2000),PATCHES_NOT_IN_IMAGE varchar2(2000),sid_serial varchar2(20));
  type wc_details_tt is table of wc_details_rt;

  FUNCTION list_homes (p_cursor  IN  t_rhp_servers_ref_cursor)
    RETURN wc_tt PIPELINED
    CLUSTER  p_cursor BY (ip)
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (ip));   
  FUNCTION list_homes_details (p_cursor  IN  wc_details_ref_cursor)
    RETURN wc_details_tt PIPELINED
    CLUSTER  p_cursor BY (cluster_name)
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (cluster_name));   
  FUNCTION list_images (p_cursor  IN  t_rhp_servers_ref_cursor)
    RETURN img_tt PIPELINED
    CLUSTER  p_cursor BY (ip)
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (ip));   
  FUNCTION list_image_drift (p_cursor  IN  t_rhp_servers_ref_cursor)
    RETURN img_tt PIPELINED
    CLUSTER  p_cursor BY (ip)
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (ip));   
END RHP_rpt;
/


CREATE OR REPLACE PACKAGE BODY RHP_rpt AS
  FUNCTION list_homes (p_cursor  IN  t_rhp_servers_ref_cursor)
    RETURN wc_tt PIPELINED
    CLUSTER p_cursor BY (ip)
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (ip))
  IS
    l_row  t_rhp_servers_rt;
    w_row  wc_rt;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.cluster_name,
            l_row.ip,
            l_row.enabled;
      EXIT WHEN p_cursor%NOTFOUND;  
      for pom in (select workingcopy from json_table(rest_demo('https://'||l_row.ip||':8894/rhp-restapi/rhp/workingcopies'),'$.items[*]' error on error
        columns (uri varchar2(300) PATH '$.links.uri', workingcopy varchar2(50) PATH '$.workingCopyId')) ) 
        loop 
        w_row.cluster_name:=l_row.ip;
        w_row.workingcopy:=pom.workingcopy;
        SELECT  Sys_Context('USERENV', 'SID')||','||Sys_Context('USERENV', 'SESSIONID')
        into w_row.sid_serial
        FROM dual;
        PIPE ROW (w_row);
      end loop;
    END LOOP;
    RETURN;
  END list_homes;  

  FUNCTION list_homes_details (p_cursor  IN  wc_details_ref_cursor)
    RETURN wc_details_tt PIPELINED
    CLUSTER  p_cursor BY (cluster_name)
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (cluster_name))   
  IS
    l_row  wc_rt;
    w_row  wc_details_rt;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.cluster_name,
            l_row.workingcopy;
      EXIT WHEN p_cursor%NOTFOUND;  
      for pom in (select IMAGENAME,workingcopy,databases,groups,oracle_home,oracle_base,patches,PATCHES_NOT_IN_IMAGE
                  from json_table(rest_demo('https://'||l_row.cluster_name||':8894/rhp-restapi/rhp/workingcopies/'||l_row.workingcopy),'$'
                                  error on error
                                  columns (imageName varchar2(30) PATH '$.imageName',
                                           workingCopy varchar2(30) PATH '$.workingCopyId',
                                           Databases varchar2(2000) FORMAT JSON PATH '$.configuredDatabases',
                                           groups varchar2(100) FORMAT JSON PATH '$.groupsConfiguredInWorkingCopy',
                                           ORACLE_HOME varchar2(300) PATH '$.softwareHomePath',
                                           ORACLE_BASE varchar2(200) PATH '$.oracleBase',
                                           PATCHES varchar2(2000) PATH '$.allPatchesAvailableInHome',
                                           PATCHES_NOT_IN_IMAGE varchar2(2000) PATH '$.additionalPatchesComparedToImage')) )  loop 
        w_row.cluster_name:=l_row.cluster_name;
        w_row.imagename:=pom.imagename;
        w_row.workingcopy:=pom.workingcopy;
        w_row.databases:=pom.databases;
        w_row.groups:=pom.groups;
        w_row.oracle_home:=pom.oracle_home;
        w_row.oracle_base:=pom.oracle_base;
        w_row.patches:=pom.patches;
        w_row.PATCHES_NOT_IN_IMAGE:=pom.PATCHES_NOT_IN_IMAGE;
        SELECT  Sys_Context('USERENV', 'SID')||','||Sys_Context('USERENV', 'SESSIONID')
        into w_row.sid_serial
        FROM dual;
        PIPE ROW (w_row);
      end loop;
    END LOOP;
    RETURN;
  END list_homes_details;   
  
  FUNCTION list_images (p_cursor  IN  t_rhp_servers_ref_cursor)
    RETURN img_tt PIPELINED
    CLUSTER p_cursor BY (ip)
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (ip))
  IS
    l_row  t_rhp_servers_rt;
    w_row  img_rt;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.cluster_name,
            l_row.ip,
            l_row.enabled;
      EXIT WHEN p_cursor%NOTFOUND;  
      for pom in (select image from json_table(rest_demo('https://'||l_row.ip||':8894/rhp-restapi/rhp/images'),'$.items[*]' error on error
        columns (uri varchar2(300) PATH '$.links.uri', image varchar2(50) PATH '$.imageId')) ) 
        loop 
        w_row.cluster_name:=l_row.ip;
        w_row.image:=pom.image;
        SELECT  Sys_Context('USERENV', 'SID')||','||Sys_Context('USERENV', 'SESSIONID')
        into w_row.sid_serial
        FROM dual;
        PIPE ROW (w_row);
      end loop;
    END LOOP;
    RETURN;
  END list_images;      
  FUNCTION list_image_drift (p_cursor  IN  t_rhp_servers_ref_cursor)
    RETURN img_tt PIPELINED
    CLUSTER p_cursor BY (ip)
    PARALLEL_ENABLE(PARTITION p_cursor BY HASH (ip))
  IS
    l_row  t_rhp_servers_rt;
    w_row  img_rt;
  BEGIN
    LOOP
      FETCH p_cursor
      INTO  l_row.cluster_name,
            l_row.ip,
            l_row.enabled;
      EXIT WHEN p_cursor%NOTFOUND;  
      for pom in (select image from json_table(rest_demo('https://'||l_row.ip||':8894/rhp-restapi/rhp/images/search?drift=true'),'$.items[*]' error on error
        columns (uri varchar2(300) PATH '$.links.uri', image varchar2(50) PATH '$.imageId')) ) 
        loop 
        w_row.cluster_name:=l_row.ip;
        w_row.image:=pom.image;
        SELECT  Sys_Context('USERENV', 'SID')||','||Sys_Context('USERENV', 'SESSIONID')
        into w_row.sid_serial
        FROM dual;
        PIPE ROW (w_row);
      end loop;
    END LOOP;
    RETURN;
  END list_image_drift; 
END RHP_rpt;
/
