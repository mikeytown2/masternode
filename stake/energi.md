# Table of Contents
1. [Quick Guide](#quick-guide)
1. [VPS Staking Guide](#vps-staking-guide)
1. [Troubleshooting / FAQ](#troubleshooting--faq)
1. [Appendix](#appendix)
1. [Energi Tip Address](#nrg-tip-address)

---
---

# Quick Guide
On your VPS run this to get VPS staking setup  

    bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stake/energid.sh)" ; source ~/.bashrc

`O` and `o` are both the letter and not the number if you are typing this out.  
[Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) is highly recommended in order to use copy/paste (for windows).  
You can view the script here https://github.com/mikeytown2/masternode/blob/master/stake/energid.sh.  
At the prompts reply with `y` (recommended). 

___  
___  

# VPS Staking Guide

What you need:  
- A Ubuntu 16.04 OR 18.04 Virtual Private Server ([VPS](https://www.vultr.com/?ref=7876413-4F)) for running the staking node 
- Be sure to setup 2 factor auth for vultr; see https://my.vultr.com/settings/twofactor/ 
- A way to use SSH ([Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) for windows or Terminal for Mac)  
- [Energi Wallet](https://github.com/energicryptocurrency/energi/releases/latest) ([Windows](https://github.com/energicryptocurrency/energi/releases/download/v2.2.1/energicore-2.2.1-win64-setup.exe),
 [Mac](https://github.com/energicryptocurrency/energi/releases/download/v2.2.1/energicore-2.2.1-macos.dmg), 
 [Linux](https://github.com/energicryptocurrency/energi/releases/download/v2.2.1/energicore-2.2.1-linux.tar.gz))
- [recommended at least 100 NRG Coins](https://coinmarketcap.com/currencies/energi/#markets)
- Help can be found on the [Discord chat](https://discord.gg/QACDTxt). 
  BE CAREFUL; only trust help via the ticket support system.
  Usernames are not unique on discord so only trust green, yellow, blue, and red users (people with roles) IN the Energi Discord server.

<details><summary id="win"><strong>Click here for the Windows Setup:</strong></summary>

#### 1.0 Wallet Prep.  
Enable coin control features. 
In the desktop wallet go to Settings -> Options -> Wallet and make sure Enable coin control features is checked and click OK.  
![](https://i.imgur.com/TiqP96p.png "")  

#### 2.0 Next you'll need a VPS.
Any VPS provider will work; in this example vultr will be used.
Get a VPS from here
https://www.vultr.com/?ref=7876413-4F

Once signed up go here https://my.vultr.com/deploy/  

1. Choose Server  
   ![](https://i.imgur.com/gAfrQIq.png "")  
1. Select a location  
   ![](https://i.imgur.com/njK2ncr.png "")  
1. Select Ubuntu 18.04  
   ![](https://i.imgur.com/B3vKhdJ.png "")  
1. Select $3.50  
   ![](https://i.imgur.com/jgVFGDI.png "")  
1. Click deploy now button  
   ![](https://i.imgur.com/39rK5xl.png "")  

Once deployed (wait 2 minutes)  
![](https://i.imgur.com/SySIwzL.png "")  

##### 3.0 Login to VPS via SSH.  
Click the Cloud Instance link on the left or the Manage link/Server Details on the right  
![](https://i.imgur.com/g0Jdj4O.png "")  

Under IP click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon" )  
![](https://i.imgur.com/49G3uam.png "")  

![](https://i.imgur.com/XOFN9EW.png  "")  
Open up [Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) and paste in the IP of your VPS into the Host field under Server on the left side. 
To the right of that in the Username field put in `root` and change Initial method to `keyboard-interactive`.  
Click the login button  
![](https://i.imgur.com/DG2oZn9.png  "")  
Click Accept and Save for host key verification  
![](https://i.imgur.com/oewSrev.png  "")  

Go back to the vultr Server Information page and under password click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon")  
![](https://i.imgur.com/hRb01oa.png "")  
Then paste in the password from vultr.  
![](https://i.imgur.com/ASWvnWp.png "")  


#### 4.0 VPS Steps

Copy the following line and paste into your remote terminal and press enter (right click to paste in Bitvise) ([How to connect to your VPS (3.0)](#30-get-vps-ip)).  

    bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stake/energid.sh)" ; source ~/.bashrc  

`O` and `o` are both the letter and not the number if you are typing this out.  
[Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) is highly recommended in order to use copy/paste.  
You can view the script here https://github.com/mikeytown2/masternode/blob/master/stake/energid.sh
![](https://i.imgur.com/dgQZWWn.png "")  

Type in `y` when it asks to "Proceed with the script (y/n)?:"
![](https://i.imgur.com/cea9Sfc.png "")  
This will take about 10 minutes to update Ubuntu 18.04 to the latest package versions. 
Please wait for Linux to be updated.

Type in `y` when it asks to "Make it so only the above list of users can login via SSH (y/n)?:"
![](https://i.imgur.com/y1TeTc5.png "")  

Scan in your QR code and confirm it works by typing in the 6 digit code.
![](https://i.imgur.com/6snmtDy.png "")  

Write down the emergency scratch codes and then type in `y`
to use this 2 factor code.
![](https://i.imgur.com/kCn0ITN.png "")  

Type in `y` when it asks to "Install a new energid node on this vps (y/n)?:"
![](https://i.imgur.com/IWB6Pzt.png "")  

Give it time to install the node on your Linux box
![](https://i.imgur.com/1ZeSnBb.png "")  

#### 5.0 Upload your wallet.dat to the VPS

This script uses https://send.firefox.com/ to transfer files from your desktop computer onto the vps. 
All files are encrypted before being uploaded and decrypted on the client after downloading. 
The encryption key is never sent to the server. 

You should be at this point now.  
![](https://i.imgur.com/bzJFhPy.png "")  

Shutdown the energi wallet.

Open up the energicore folder.  
windows key + r  
`explorer.exe %appdata%\energicore`  
![](https://i.imgur.com/v5qnHAg.png "")  

If you see the database folder; please turn off the energi wallet  
![](https://i.imgur.com/PO3tng9.png "")  

Please go to https://send.firefox.com/  
![](https://i.imgur.com/3Rr8fDU.png "")  

Select wallet.dat and drag it into your browser to upload it  
![](https://i.imgur.com/kGJ7qx2.png "")  
![](https://i.imgur.com/agvAV66.png "")  

Click the upload button and then copy link  
![](https://i.imgur.com/c2weNT5.png "")  

Then go to the ssh terminal and paste in (right click) the link and press enter.  
![](https://i.imgur.com/uq2IDbB.png "")  
Fill in the password you set on send.firefox.com if you set one.  

Wait for the wallet to load  
![](https://i.imgur.com/bdcWWEj.png "")  

Enter in your wallet's password  
![](https://i.imgur.com/3Y6RGf1.png "")  

##### 6.0 Script will end with  
Script will end with the amount of energi in the wallet.  
The amount of energi that is staking.  
The staking status.  
![](https://i.imgur.com/FXfWo3E.png "")  


##### 7.0 Edit energi.conf on your desktop
windows key + r  
`notepad.exe %appdata%\energicore\energi.conf`  
and add in  
`staking=0`  

##### 8.0 Notes
You can re-run the staking script to continue where you left off OR to upload a different wallet.dat file.

If you messed up and want to start over with a fresh VPS instance go to https://my.vultr.com/ 
click on the three dots to the right ... and select Server Reinstall.

</details>

<details><summary id='mac'><b>Click here for the Mac Setup:</b></summary>
    
#### 1.0 Wallet Prep.  
Enable coin control features. 
In the desktop wallet go to Energi -> Preferences -> Wallet and make sure Enable coin control features is checked and click OK.  
![](https://i.imgur.com/YsLF7FW.png "")  

#### 2.0 Next you'll need a VPS.
Any VPS provider will work; in this example vultr will be used.
Get a VPS from here
https://www.vultr.com/?ref=7876413-4F

Once signed up go here https://my.vultr.com/deploy/  

1. Choose Server  
   ![](https://i.imgur.com/gAfrQIq.png "")  
1. Select a location  
   ![](https://i.imgur.com/njK2ncr.png "")  
1. Select Ubuntu 18.04  
   ![](https://i.imgur.com/B3vKhdJ.png "")  
1. Select $3.50  
   ![](https://i.imgur.com/jgVFGDI.png "")  
1. Click deploy now button  
   ![](https://i.imgur.com/39rK5xl.png "")  

Once deployed (wait 2 minutes)  
![](https://i.imgur.com/SySIwzL.png "")  

##### 3.0 Login to VPS via SSH.  
Click the Cloud Instance link on the left or the Manage link/Server Details on the right  
![](https://i.imgur.com/g0Jdj4O.png "")  

Under IP click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon" )  
![](https://i.imgur.com/49G3uam.png "")  
 
Finder -> Menubar (top of screen) -> Go -> Utilities. Open Terminal.  
Then from the menubar to Shell -> New Remote Connection.  
![](https://i.imgur.com/djlgZ7f.png  "")  

Select Secure Shell (ssh); then click the right +.
In the field paste in the ip address of your VPS.  
![](https://i.imgur.com/NlGZqyw.png  "")  
Click the Connect button.  
![](https://i.imgur.com/v6TcEKM.png  "")  
Type in `yes` here  
![](https://i.imgur.com/MFx4817.png  "")  

Go back to the vultr Server Information page and under password click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon")  
![](https://i.imgur.com/hRb01oa.png "")  
Then paste in the password from vultr and press enter. 
Note that there will not be any \*\*\*\*\*\*\*\* when you paste in the password.  
![](https://i.imgur.com/rodtUzV.png "")  


#### 4.0 VPS Steps

Copy the following line and paste into your remote terminal and press enter ([How to connect to your VPS (3.0)](#30-get-vps-ip)).  

    bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stake/energid.sh)" ; source ~/.bashrc  

`O` and `o` are both the letter and not the number if you are typing this out.  
[Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) is highly recommended in order to use copy/paste.  
You can view the script here https://github.com/mikeytown2/masternode/blob/master/stake/energid.sh
![](https://i.imgur.com/eHHs6eD.png "")  

Type in `y` when it asks to "Proceed with the script (y/n)?:"
![](https://i.imgur.com/plcq07d.png "")  
This will take about 10 minutes to update Ubuntu 18.04 to the latest package versions. 
Please wait for Linux to be updated.

Type in `y` when it asks to "Make it so only the above list of users can login via SSH (y/n)?:"
![](https://i.imgur.com/Xib0pXJ.png "")  

Scan in your QR code and confirm it works by typing in the 6 digit code.  
You'll want to make the terminal window bigger here to more easily scan in the QR code.  
![](https://i.imgur.com/LJe2xs3.png "")  

Write down the emergency scratch codes and then type in `y`
to use this 2 factor code.
![](https://i.imgur.com/cs6ZZFC.png "")  

Type in `y` when it asks to "Install a new energid node on this vps (y/n)?:"
![](https://i.imgur.com/UPDTtjQ.png "")  

Give it time to install the node on your Linux box
![](https://i.imgur.com/mvGHhsD.png "")  


#### 5.0 Upload your wallet.dat to the VPS

This script uses https://send.firefox.com/ to transfer files from your desktop computer onto the vps. 
All files are encrypted before being uploaded and decrypted on the client after downloading. 
The encryption key is never sent to the server. 

You should be at this point now.  
![](https://i.imgur.com/qL8b5EV.png "")  

Shutdown the energi wallet.

Open up the energicore folder (~/Library/Application Support/EnergiCore).  
Terminal -> Menubar (top of screen) -> Shell -> New Window -> New Window with Settings - Basic  
Type/Paste in 

    open "${HOME}/Library/Application Support/EnergiCore"

![](https://i.imgur.com/ADTVntH.png "")  

If you see the database folder; please turn off the energi wallet  
![](https://i.imgur.com/C4nHdRz.png "")  

Please go to https://send.firefox.com/  
![](https://i.imgur.com/3Rr8fDU.png "")  

Select wallet.dat and drag it into your browser to upload it  
![](https://i.imgur.com/9V3EviE.png "")  
![](https://i.imgur.com/agvAV66.png "")  

Click the upload button and then copy link  
![](https://i.imgur.com/c2weNT5.png "")  

Then go to the ssh terminal and paste in the link and press enter.  
![](https://i.imgur.com/PbuAW1f.png "")  
Fill in the password you set on send.firefox.com if you set one.  

Wait for the wallet to load  
![](https://i.imgur.com/vyOwZYR.png "")  

Enter in your wallet's password  
![](https://i.imgur.com/sloB52B.png "")  

##### 6.0 Script will end with  
Script will end with the amount of energi in the wallet.  
The amount of energi that is staking.  
The staking status.  
![](https://i.imgur.com/6Y9IinA.png "")  


##### 7.0 Edit energi.conf on your desktop
Terminal -> Menubar (top of screen) -> Shell -> New Window -> New Window with Settings - Basic  
Type/Paste in 

    open -a TextEdit "${HOME}/Library/Application Support/EnergiCore/energi.conf"  

and add in  
`staking=0`  

##### 8.0 Notes
You can re-run the staking script to continue where you left off OR to upload a different wallet.dat file.

If you messed up and want to start over with a fresh VPS instance go to https://my.vultr.com/ 
click on the three dots to the right ... and select Server Reinstall.


</details>

___  
___  

# Troubleshooting / FAQ  

<details><summary id="backup"><strong> How do I backup my wallet? </strong></summary>

Make sure it's been encrypted with a password and then store the wallet.dat file on 
[Dropbox](https://www.dropbox.com/) or [Google Drive](https://drive.google.com/). 
Make sure the cloud backup provider has 2 factor authentication enabled 
([Google](https://support.google.com/accounts/answer/185839?hl=en), 
[Dropbox](https://www.dropbox.com/help/security/enable-two-step-verification)). 
On windows the wallet can be found in the `%appdata%/energicore` directory 
(windows key + r `%appdata%/energicore` and if that doesn't work try `%userprofile%\AppData\Roaming\energicore`). 
On Mac it can be found in the `~/Library/Application Support/EnergiCore` directory; 
Finder -> Menubar (top of screen) -> Go -> Utilities, open Terminal, type in `open ~/Library/Application\ Support/EnergiCore`.

You can also backup via `dumpwallet`.  
Go to tools -> debug console and type in `dumpwallet enrg.txt`.  
enrg.txt is usually put in the same folder as the energi wallet executable.  
Print this out and keep it in a safe place.  

</details>

<details><summary id="file-recovery"><strong> How do I recover a deleted wallet.dat </strong></summary>

Download Recuva: https://www.ccleaner.com/recuva/download/standard  
Once you install run it and select all files  
![](https://i.imgur.com/MI3iDBt.png "")  
Search in the  
`C:\Users\username\AppData\Roaming\EnergiCore`  
folder replacing `username` with the correct path.  
![](https://i.imgur.com/d7NYyXN.png "")  
Check enable deep scan  
![](https://i.imgur.com/nSJ6oKK.png "")  
Wait for it to scan your hard drive and then look for any files with wallet.dat in the name.  

</details>


<details><summary id="hd-recovery"><strong> How do I recover a hard drive that doesn't work at all </strong></summary>

If the drive still spins up but won't boot up and you suspect very minor damage SpinRite might be able to help.      
https://www.grc.com/cs/prepurch.htm  

If your drive needs a lot of help checkout professional data recovery services like this one.  
https://rossmanngroup.com/data-recovery-service-nyc/  

</details>


<details><summary id="edit-energi"><strong> Edit energi.conf </strong></summary>

Tools -> Open wallet configuration file.

If the above doesn't work you can do this:  
Windows:  
windows key + r  
`notepad %appdata%/energicore/energi.conf`  
Copy Paste the above line into the run dialog box.

Mac:  
go to Finder -> Menubar (top of screen) -> Go -> Utilities, open Terminal, type in  
`open -a TextEdit ~/Library/Application\ Support/EnergiCore/energi.conf`  
If you already have a terminal window open and want another one go to the Menubar (top of screen) -> new window -> new windows with profile - basic. Then paste in the above command.

</details>

<details><summary id="fastsync-windows"><strong> Use the snapshot on windows </strong></summary>

#### Automatic 

1. Close out the Energi Wallet.  
2. Download and run this file: [energi-qt.bat](https://raw.githack.com/mikeytown2/masternode/master/qt/energi-qt.bat).  
3. Wait for the energi wallet to start up again (give it about 10 min to start after running the bat file).  

#### Manual

1. Download the latest snapshot [here](https://www.dropbox.com/s/gsaqiry3h1ho3nh/blocks_n_chains.tar.gz?dl=1)
2. Close out the Energi Wallet.
3. You'll need [7zip](https://www.7-zip.org/download.html) to open up the tar.gz file. Go to the energicore folder
windows key + r  
```
explorer.exe %appdata%\energicore
```
and if that doesn't work try  
```
explorer.exe %userprofile%\AppData\Roaming\energicore
```
4. And then delete everything in the energicore folder **except** for  
- the backups folder  
- wallet.dat  
- masternode.conf  
- energi.conf  
5. Extract the contents of the archive into the energicore folder.  
6. Start wallet up again.  

</details>

<details><summary id="vps-lockout"><strong> I've been locked out of the VPS </strong></summary>
    
You get one of these errors when trying to login via Bitvise:  
"Network error: Connection timed out"  
"Network error: Software caused a connection abort"  

Go here to get your IP address: http://ipinfo.io/ip.
Then you'll need to login to the box via the "view console" button on the vultr manage page.
once logged in type this in  

    denyhosts_unblock YOUR.DESKTOP.IP.ADDRESS

Replace "YOUR.DESKTOP.IP.ADDRESS" with the numbers found on http://ipinfo.io/ip

</details>

<details><summary id="websites"><strong> Useful Websites </strong></summary>

Energi Website  
https://www.energi.world/  

Block Explorer  
https://explore.energi.network/  
https://explore2.energi.network/  

Coinmarketcap  
https://coinmarketcap.com/currencies/energi/  

</details>


---
---

# Appendix

<details><summar id="vps-commands"y><strong>Useful commands to run on your VPS:</strong></summary>

Get the staking status  
`energi-cli getstakingstatus`  

Get the total number of NRG coins the wallet has  
`energi-cli getbalance`  

Get the total number of NRG coins that will be staked  
`energi-cli liststakeinputs balance`  

Get how long the daemon has been running for in seconds.  
`energi-cli uptime`  

Compare the local blockcount and the explorer’s blockcount.  
`energi-cli blockcheck`  

Download the blocks and chainstake folders; fairly close to a new install. Will get the node back on the correct chain.  
`energi-cli dl_blocks_n_chains`  

Check github for a new version; and update if there is a new version.  
`energi-cli update_daemon`  

Delete the node off of the VPS.  
`energi-cli remove_daemon`  

Restart the daemon.  
`energi-cli restart`  

Watch the last 20 entries in the daemon log  
`energi-cli daemon_log tail 20 watch`  

Get the last 2 entries in the daemon log that deal with the node startup and shutdown  
`energi-cli daemon_log starts 2 20`  

</details>

---
---

# NRG Tip Address #
EfQZJxx86Xa2DqzP9Hdgv7HQe1MtYzQpDC


---
---

