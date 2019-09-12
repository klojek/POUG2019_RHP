# POUG2019_RHP

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


