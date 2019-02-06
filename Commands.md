Replace pivx_mn1 with the masternode username on your vps OR replace with all_mn_run to run that command on all nodes on this VPS.

## Run Same Command on All Masternodes
#### all_mn_run **daemon**
Get the daemon name for all the masternodes running on this VPS.

#### all_mn_run **DAEMON_NAME pivxd update_daemon force**
Update the masternode binary code for all masternodes that have a daemon called pivxd.

#### all_mn_run **ONE_DAEMON explorer**
Get the explorer URL for every masternode running on this VPS.

## Popular Commands
#### pivx_mn1 **blockcheck**  
Compare the local getblockcount and the explorers block count.

#### pivx_mn1 **masternode status**
Get masternode status on vps.

#### pivx_mn1 **mninfo**
Get masternode from masternode list.

#### pivx_mn1 **mnping**
Get last masternode ping thats been sent out.

#### pivx_mn1 **ps**
Get process info on the node.

#### pivx_mn1 **privkey**
Get the masternode private key.

#### pivx_mn1 **uptime**
Get how long the daemon has been running for in seconds.

#### pivx_mn1 **restart**
Restart the daemon.

#### pivx_mn1 **dl_blocks_n_chains**
Download the blocks and chainstake folders if old; fairly close to a new install.
#### pivx_mn1 **dl_blocks_n_chains force**
Download the blocks and chainstake folders even if newly downloaded; fairly close to a new install.

#### pivx_mn1 **sync**
Show inital block sync progress.


#### pivx_mn1 **update_daemon**
Check github for a new version.
#### pivx_mn1 **update_daemon force**
Update daemon to the latest version on github.

#### pivx_mn1 **remove_daemon**
Delete the masternode off of the VPS.

## All Other Commands 
#### pivx_mn1 **addnode_console**
Generate an addnode list of peers that have the same blockcount as the explorer. List is in the format for adding via the debug console.

#### pivx_mn1 **addnode_list**
Generate an addnode list of peers that have the same blockcount as the explorer. List is in the format for adding via the wallet configuration file.

#### pivx_mn1 **addnode_remove**
Remove any addnode= lines in the VPS wallet configuration file. 

#### pivx_mn1 **addnode_to_connect**
Change the addnode= lines to connect= in the VPS wallet configuration file. 

blockcheck_fix  
blockcheck_reindex  

#### pivx_mn1 **chaincheck**
#### pivx_mn1 **checkchain**
Compare the local getblockchaininfo and the explorers block chain info (if the explorer supports it).

#### pivx_mn1 **checksystemd**
#### pivx_mn1 **systemdcheck**
See if systemd is enabled active and running.

#### pivx_mn1 **log_daemon**
#### pivx_mn1 **daemon_log**
Print the contents of debug.log
#### pivx_mn1 **daemon_log loc**
Print the location of debug.log
#### pivx_mn1 **daemon_log grep** ***"Search Term"***
Search the logs for that exact text string.

#### pivx_mn1 **explorer** 
Get the block explorers URL.

blockcount_explorer
#### pivx_mn1 **explorer_blockcount** 
Get the block explorers blockcount.

#### pivx_mn1 **explorer_peers**
Get the peers connected to the block explorer.
#### pivx_mn1 **explorer_peers**
Get the peers connected to the block explorer.



#### pivx_mn1 **getmasternodever**
See what versions the masternodes in masternode list are running (doesn't work for every coin).


blockcount_explorer  
chaincheck  
checkblock  
checkchain  
checkpeers  
checksystemd  
cli  
conf  
connect_to_addnode  
console_addnode  
crontab  
daemon  
daemon_in_good_state  
daemon_log  
daemon_remove  
daemon_update  
dl_addnode  
dl_blocks_n_chains  
dl_bootstrap  
dl_bootstrap_reindex  
explorer  
explorer_blockcount  
explorer_peers  
failure_after_start  
forcestart  
getmasternodever  
getmasternodeversion  
getpeerblockcount  
getpeerblockver  
getpeerver  
getpeerversion  
githubrepo  
lastblock  
lastblock_time  
list_addnode  
log_daemon  
log_system  
masternode.conf  
mnaddr  
mnbal  
mncheck  
mnfix  
mninfo  
mnlocal  
mnping  
mnver  
mnwin  
peercheck  
peers_remove  
pid  
port  
privkey  
ps  
ps-short  
reindex  
reindexzerocoin  
remove_addnode  
remove_daemon  
remove_peers  
rename  
restart  
start  
start-nosystemd  
status  
stop  
sync  
systemdcheck  
system_log  
update_daemon  
uptime  
