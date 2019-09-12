# POUG2019_RHP
Simple demo project created for POUG Conference

## Files:
```
POUG2019_RHP.pdf - the presentation
REST_DEMO.pls - function to send requests to RHP servers
RHP_image.sql - select statements to list and import the gold images 
RHP_workingcopy.sql - select statements to list and provision oracle homes (workingcopies)
RHP_DBPATCH.sql - select statements to move databases to new oracle home and patch
RHP_JOBS.sql - select statements to list the job details and the job logs
RHP_RPT.pls - demo package specification and body for some reporting across multiple RHP servers
RHP_rpt.sql - select statements to do some reporting across all RHP servers
```
## installation
1. create a mgmtdb (Doc ID 2065175.1)
```
./mdbutil.pl -addmdb --target=<diskgroup>
```
2. enable GHCHKPT volume
```
srvctl enable volume -volume GHCHKPT -diskgroup <diskgroup>
srvctl enable filesystem -volume GHCHKPT -diskgroup <diskgroup>
srvctl start filesystem -volume GHCHKPT -diskgroup <diskgroup>
```
3. setup the rhpserver (Doc ID 2097026.1)
3.1 GNS setup
```
srvctl add gns -vip <vip_name|ip>
srvctl start gns
```
3.2 RHP setup
```
rhpctl stop rhpserver
rhpctl delete rhpserver #if it was installed in local mode
rhpctl add rhpserver -diskgroup <diskgroup> -storage <rhp_acfs_path> 
srvctl start rhpserver #włączenie rhpserver
```
3.3 enable REST
```
rhpctl register user -restuser -user <REST_username> -email <email_notification> -rhpuser <GI_owner>
srvctl stop rhpserver
srvctl modify rhpserver -enableHTTPS YES
srvctl start rhpserver
```
3.4 verify REST
```
crskeytoolctl -printrootcert
```
> [grid@exa01vm02 ~]$ crskeytoolctl -printrootcert  
> Cluster root public certificate printed to file [/home/grid/b441af55ae504f74ffe6274d65e0d979.pem].
```
export CURL_CA_BUNDLE=<cert_file_name>
curl -u <REST_username> https://<REST_SERVER_NAME>:8894/rhp-restapi/rhp/workingcopies
```
> [grid@exa01vm02 ~]$ curl -u resttest https://exa01vm02:8894/rhp-restapi/rhp/workingcopies  
> Enter host password for user 'resttest':  
> {"items":[]}

4. configure database
4.1 create wallet
```
orapki wallet create -wallet <wallet_path> -pwd <wallet_pwd> -auto_login
orapki wallet add -wallet <wallet_path> -trusted_cert -cert <cert_file_name> -pwd <wallet_pwd>
mkstore -wrl <wallet_path> -createCredential <cred_name> <REST_username>
```
> orapki wallet create -wallet /acfs01/wallet/exa01vm02 -pwd We1come4 -auto_login  
> Oracle PKI Tool Release 18.0.0.0.0 - Production  
> Version 18.1.0.0.0  
> Copyright (c) 2004, 2017, Oracle and/or its affiliates. All rights reserved.  
>  
>Operation is successfully completed.  
> orapki wallet add -wallet /acfs01/wallet/exa01vm02 -trusted_cert -cert ./d473bbbc02425f5fbfc42872637e7aa0.pem -pwd We1come4  
> Oracle PKI Tool Release 18.0.0.0.0 - Production  
> Version 18.1.0.0.0  
> Copyright (c) 2004, 2017, Oracle and/or its affiliates. All rights reserved.  
>  
>Operation is successfully completed.  
> mkstore -wrl /acfs01/wallet/exa01vm02 -createCredential exa01vm02 resttest  
> Oracle Secret Store Tool Release 18.0.0.0.0 - Production  
> Version 18.1.0.0.0  
> Copyright (c) 2004, 2017, Oracle and/or its affiliates. All rights reserved.  
>  
> Your secret/Password is missing in the command line  
> Enter your secret/Password:    
> Re-enter your secret/Password:    
> Enter wallet password:  
4.2 create ACL
```
BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl(
    acl => <name>, 
    description=> <description>,
    principal => <DB_USER>, 
    is_grant => TRUE, 
    privilege => 'connect'); 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
    acl => <name>,
    principal => <DB_USER>, 
    is_grant => TRUE, 
    privilege => 'use-passwords'); 
  DBMS_NETWORK_ACL_ADMIN.assign_acl(
    acl => <name>, 
    host => <RHP_server>); 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_WALLET_acl(
    acl => <name>, 
    wallet_path =>'file:<wallet_path>'); 
  commit;
END; 
/
```
> BEGIN  
>   DBMS_NETWORK_ACL_ADMIN.create_acl(  
>     acl => 'RHP_TEST.xml',  
>     description=> 'RHP TEST',  
>     principal => 'REST_DEMO',  
>     is_grant => TRUE,  
>     privilege => 'connect');  
>   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(  
>     acl => 'RHP_TEST.xml',  
>     principal => 'REST_DEMO',   
>     is_grant => TRUE,   
>     privilege => 'use-passwords');  
>   DBMS_NETWORK_ACL_ADMIN.assign_acl(  
>     acl => 'RHP_TEST.xml',  
>     host => '*');  
>   DBMS_NETWORK_ACL_ADMIN.ASSIGN_WALLET_acl(  
>     acl => 'RHP_TEST.xml',  
>     wallet_path =>'file:/acfs01/wallet/exa01vm02');  
>   commit;  
> END;  
> /  
4.3 create rest_demo function
```
  @rest_demo.pls
```
4.4 play with select statements

