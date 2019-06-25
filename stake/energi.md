# Table of Contents
1. [Quick Guide](#quick-guide)
1. [Masternode Guide](#masternode-guide)
1. [Linux QT Wallet Install](#linux-qt-wallet-install)
1. [Troubleshooting / FAQ](#troubleshooting--faq)
1. [Appendix](#appendix)
1. [Energi Tip Address](#nrg-tip-address)

---
---

# Quick Guide
On your VPS run this to get VPS staking stup  

    bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stake/energid.sh)" ; source ~/.bashrc

`O` and `o` are both the letter and not the number if you are typing this out.  
[Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) is highly recommended in order to use copy/paste (for windows).  
You can view the script here https://github.com/mikeytown2/masternode/blob/master/stake/energid.sh.  
At the prompts reply with `y` (recommended). 

___  
___  

# VPS Staking Guide

What you need:  
- A Ubuntu 16.04 OR 18.04 Virtual Private Server ([VPS](https://www.vultr.com/?ref=7333199)) for running the staking node  
- A way to use SSH ([Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) for windows or Terminal for Mac)  
- [Energi Wallet](https://github.com/energicryptocurrency/energi/releases/latest) ([Windows](https://github.com/energicryptocurrency/energi/releases/download/v2.2.1/energicore-2.2.1-win64-setup.exe),
 [Mac](https://github.com/energicryptocurrency/energi/releases/download/v2.2.1/energicore-2.2.1-macos.dmg), 
 [Linux](https://github.com/energicryptocurrency/energi/releases/download/v2.2.1/energicore-2.2.1-linux.tar.gz))
- [recommended at least 100 NRG Coins](https://coinmarketcap.com/currencies/energi/#markets)
- Help can be found on the [Discord chat](https://discord.gg/QACDTxt). 
  BE CAREFULL; only trust help via the ticket support system.
  Usernames are not unique on discord so only trust green, yellow, blue, and red users (people with roles) IN the Energi Discord server.

<details><summary><h2>Windows Setup:</h2></summary>

#### 1.0 Wallet Prep.  
Enable coin control features and Show Masternodes Tab. 
In the desktop wallet go to Settings -> Options -> Wallet and make sure Enable coin control features is checked and click OK.  
![](https://i.imgur.com/TiqP96p.png "")  

#### 2.0 Next you'll need a VPS.
Any VPS provider will work; in this example vultr will be used.
Get a VPS from here
https://www.vultr.com/?ref=7333199

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

##### 3.0 Get vps IP.  
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

Copy the following line and paste into your remote terminal and press enter (right click to paste in Bitvise) ([How to connecto to your VPS (3.0)](#30-get-vps-ip)).  

    bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stake/energid.sh)" ; source ~/.bashrc  

`O` and `o` are both the letter and not the number if you are typing this out.  
[Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) is highly recommended in order to use copy/paste.  
You can view the script here https://github.com/mikeytown2/masternode/blob/master/stake/energid.sh
![](https://i.imgur.com/dgQZWWn.png "")  

Type in `y` when it asks to "Proceed with the script (y/n)?:"
![](https://i.imgur.com/cea9Sfc.png "")  
This will take about 10 minutes to update Ubuntu 18.04 to the latest vesrion. 
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

Give it time to install the node on your linux box
![](https://i.imgur.com/1ZeSnBb.png "")  

##### 5 Script will end with  


If you messed up and want to start over with a fresh VPS instance go to https://my.vultr.com/ 
click on the three dots to the right ... and select Server Reinstall.

</details>

<details><summary><h2>Mac Setup:</h2></summary>

#### 1.0 Wallet Prep.  
Enable coin control features and Show Masternodes Tab. 
In the desktop wallet go to Settings -> Options -> Wallet (Energi -> Preferences -> Wallet on Mac) and make sure Enable coin control features and Show Masternodes Tab is checked and click OK.  
![](https://i.imgur.com/fdf3Iml.png "")  

#### 2.0 Next you'll need a VPS.
Any VPS provider will work; in this example vultr will be used.
Get a VPS from here
https://www.vultr.com/?ref=7333199

Once signed up go here https://my.vultr.com/deploy/ 
1. Select a location  
   ![](https://i.imgur.com/WLvPLXR.png "")  
2. Select Ubuntu 18.04  
   ![](https://i.imgur.com/eRJtHgi.png "")  
3. Select $3.50  
   ![](https://i.imgur.com/0y8CcC0.jpg "")  
4. Click deploy now button  
   ![](https://i.imgur.com/39rK5xl.png "")  

Once deployed (wait 2 minutes)  
![](https://i.imgur.com/2t4Njq0.png "")  

##### 3.0 Get vps IP.  
Click the Cloud Instance link on the left or the Manage link on the right  
![](https://i.imgur.com/5N1bZBA.png "")  

Under IP click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon" )  
![](https://i.imgur.com/49G3uam.png "")  


![](https://i.imgur.com/XOFN9EW.png  "")  
Open up [Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) and paste in the IP of your VPS into the Host field under Server on the left side. 
To the right of that in the Username field put in `root` and change Initial method to `password`
Go back to the vultr Server Information page and under password click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon")  
![](https://i.imgur.com/hRb01oa.png "")  
Then in the Bitvise SSH client program under Password paste in the password from vultr. 
Finally click the login button  
![](https://i.imgur.com/j1A0hmk.png  "")  
Click Accept and Save for host key verification  
![](https://i.imgur.com/oewSrev.png  "")  


#### 4.0 VPS Steps

Copy the following line and paste into your remote terminal and press enter (right click to paste in Bitvise) ([How to connecto to your VPS (3.0)](#30-get-vps-ip)).  

    bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stake/energid.sh)" ; source ~/.bashrc`  

`O` and `o` are both the letter and not the number if you are typing this out.  
[Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe) is highly recommended in order to use copy/paste.  
You can view the script here https://github.com/mikeytown2/masternode/blob/master/stake/energid.sh
![](https://i.imgur.com/GixtXDw.png "")  

Paste in your txid from notepad (right click to paste in Bitvise) when it asks [How to get the txhash (2.5)](#25-get-txhash )  
![](https://i.imgur.com/Z8w6cyu.png "")  
Press Enter at the prompts to use the defaults.  
![](https://i.imgur.com/W7gY9wh.png "")  
If setting up more than one master node, simply re-run the script if you have a 2nd IP; 
or get a new VPS and run the script on your second one.  

##### 4.1 Script will end with  
- Auto starting energid daemon running under the newly created user  
- The long string to paste into your masternode.conf file.  

![](https://i.imgur.com/2Rmztdi.png "")  
(Highlight to copy in Bitvise)  

If you messed up and want to start over with a fresh VPS instance go to https://my.vultr.com/ 
click on the three dots to the right ... and select Server Reinstall.

</details>
---
---

# Troubleshooting / FAQ  


#### Do I need multiple IPs to run multiple masternodes on a single VPS?
You will need multiple IPs; rerun the script to setup a another masternode on your VPS once you've followed the directions on how to add another IP to your VPS.

### How do I add an IP to vultr? ###
<details><summary>Click here to see how to do so</summary>

Login to Vultr and go to the server's infromation page  
![](https://i.imgur.com/kcv3tOS.png "")  
Go to the settings page and click on "Add Another IPv4 Address"  
![](https://i.imgur.com/PVtZgA1.png "")  
Once done go to the networking configuration page  
![](https://i.imgur.com/i4bvreS.png "")  
Login to VPS and edit the /etc/netplan/10-ens3.yaml file using nano  
`nano /etc/netplan/10-ens3.yaml`  
![](https://i.imgur.com/UiuFwT4.png "")  
Remove all lines from this file using `ctrl + k`  
![](https://i.imgur.com/jBzo9T3.png "")  
Copy the configuration and paste it into the nano text editor (right click is paste in Bitvise)  
![](https://i.imgur.com/1LYVOSw.png "")  
![](https://i.imgur.com/8G5SMUp.png "")  
Press `ctrl + x` to exit  
![](https://i.imgur.com/52iMXHo.png "")  
press `y` and enter to save  
![](https://i.imgur.com/wh4xmgO.png "")  
Run `netplan apply` to apply the changes to the vps  
![](https://i.imgur.com/FZOH4zx.png "")  
You can verify that the new IP has been added by looking for the new IP in the output of this command  
`ip -o addr show`  
![](https://i.imgur.com/JrwlYtQ.png "")  

</details>

#### Can I run a masternode on my home computer?
Technically yes. You need a static IP from your ISP as well as a way to open up the port that your masternode is running on
in your router. A VPS is easier to setup and run.

#### How do I backup my wallet?  
Make sure it's been encrypted with a password and then store the wallet.dat file on 
[Dropbox](https://www.dropbox.com/) or [Google Drive](https://drive.google.com/). 
Make sure the cloud backup provider has 2 factor authentication enabled 
([Google](https://support.google.com/accounts/answer/185839?hl=en), 
[Dropbox](https://www.dropbox.com/help/security/enable-two-step-verification)). 
On windows the wallet can be found in the `%appdata%/energicore` directory 
(windows key + r `%appdata%/energicore` and if that doesn't work try `%userprofile%\AppData\Roaming\energicore`). 
On Mac it can be found in the `~/Library/Application Support/EnergiCore` directory; 
Finder -> Menubar (top of screen) -> Go -> Utilities, open Terminal, type in `open ~/Library/Application\ Support/EnergiCore`.

You can also backup via `dumpprivkey`. 
Go to tools -> debug console and type in `listaccounts`; 
then for each address name type in `getaddressesbyaccount ""`; 
then do dumpprivkey on that address like so `dumpprivkey Exxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`. 
The output from this can be used to steal your coins, and also used for backup purposes. Be careful!

You can also backup via `dumpwallet`. 
Go to tools -> debug console and type in `dumpwallet enrg.txt`. 
enrg.txt is usually put in the same folder as the energi wallet executable. 

#### How do I recover a deleted wallet.dat ####
Download Recuva: https://www.ccleaner.com/recuva/download/standard  
Once you install run it and select all files  
![](https://i.imgur.com/MI3iDBt.png "")  
Search in the  
`C:\Users\username\AppData\Roaming\EnergiCore`  
folder replaceing `username` with the correct path.  
![](https://i.imgur.com/d7NYyXN.png "")  
Check enable deep scan  
![](https://i.imgur.com/nSJ6oKK.png "")  
Wait for it to scan your harddrive and then look for any files with wallet.dat in the name.  


#### My VPS got restarted and now my masternode is not running.
You need to start the Masternode again. Unlock the Wallet. 
Energi - Wallet -> Masternodes -> Start MISSING. It should be running again.

#### Wrong amout is shown in coin control features.  
Send all coins from addreses that have a wrong amount so that the value in thoese are zero. Restart wallet. 

#### Edit masternode.conf
Tools -> Open masternode configuration file.

If the above doesn't work you can do this:  
Windows:  
windows key + r  
`nodepad %appdata%/energicore/masternode.conf`  
Copy Paste the above line into the run dialog box.  
and if that doesn't work try  
windows key + r  
`nodepad %userprofile%\AppData\Roaming\energicore\masternode.conf`  

Mac:  
go to Finder -> Menubar (top of screen) -> Go -> Utilities, open Terminal, type in  
`open -a TextEdit ~/Library/Application\ Support/EnergiCore/masternode.conf`  
If you already have a terminal window open and want another one, go to the Menubar (top of screen) -> new window -> new windows with profile - basic. Then paste in the above command.

#### Edit energi.conf
Tools -> Open wallet configuration file.

If the above doesn't work you can do this:  
Windows:  
windows key + r  
`nodepad %appdata%/energicore/energi.conf`  
Copy Paste the above line into the run dialog box.

Mac:  
go to Finder -> Menubar (top of screen) -> Go -> Utilities, open Terminal, type in  
`open -a TextEdit ~/Library/Application\ Support/EnergiCore/energi.conf`  
If you already have a terminal window open and want another one go to the Menubar (top of screen) -> new window -> new windows with profile - basic. Then paste in the above command.

#### How to double check all details of the masternode
Close and open your desktop wallet. 
Tools -> Debug Console and type in `masternode outputs` at the bottom.
Also go to Tools -> Open Masternode Configuration File.
Connect to your VPS and run these commands as the root user. 
Replace `enrg_mn1` with the username used for the masternode if needed.  
`enrg_mn1 masternode.conf`

Carefully comapre the IP, the masternodeprivkey, as well as the transaction id and output index.

#### Remove user from VPS
The following example uses the username `enrg_mn9`.  

    enrg_mn9 remove_daemon

#### I've been locked out of the VPS
You get one of these errors when trying to login via Bitvise:  
"Network error: Connection timed out"  
"Network error: Software caused a connection abort"  

Go here to get your IP address: http://ipinfo.io/ip.
Then you'll need to login to the box via the "view console" button on the vultr manage page.
once logged in type this in  

    denyhosts_unblock YOUR.DESKTOP.IP.ADDRESS

Replace "YOUR.DESKTOP.IP.ADDRESS" with the nubers found on http://ipinfo.io/ip

#### Energi Website
https://www.energi.world/

#### Coinmarketcap
https://coinmarketcap.com/currencies/energi/

#### Block Explorer
https://explore.energi.network/

#### 3rd party Monitoring service  
https://masternodes.online/monitoring/  



---
---

# Appendix

## Useful commands to run on your VPS:



---
---

# NRG Tip Address #
EfQZJxx86Xa2DqzP9Hdgv7HQe1MtYzQpDC


---
---
