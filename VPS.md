Any VPS provider will work; in this example vultr will be used.
Get a VPS from here
https://www.vultr.com/?ref=7581301

Once signed up go here https://my.vultr.com/deploy/ 
1. Select a location  
   ![](https://i.imgur.com/WLvPLXR.png "")  
2. Select Ubuntu 18.04  
   ![](https://i.imgur.com/eRJtHgi.png "")  
3. Select $3.5  
   ![](https://i.imgur.com/0y8CcC0.jpg "")  
4. Click deploy now button  
   ![](https://i.imgur.com/39rK5xl.png "")  

Once deployed (wait 2 minutes) click the Manage button on the right

Under IP click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon" )  

##### Connect to the VPS.
### Windows ###
<details><summary>Click here to read Windows SSH instructions</summary>
 
Open up [PuTTY](https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.70-installer.msi) and on the left hand side select Session  
![](https://i.imgur.com/JBSHHOA.png "")  
Paste in the IP of your VPS into the Host Name (or IP address) field. Now is a good time to save the session.
Now click open. Click Yes on the PuTTY Security Alert popup.  
![Security Alert](https://www.ssh.com/s/putty-security-alert-431x298-mqLph86E.png "Security Alert")  
`login as: root`  
Go back to the vultr manage webpage and under password click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon")  
Back on the PuTTY screen right click (right click is paste) and press enter to fill in the password. 
`root@x.x.x.x's password:`  

 </details>
 
___  

### Mac ###
<details><summary>Click here to read Mac SSH instructions</summary>
 
Finder -> Menubar (top of screen) -> Go -> Utilities. Open Terminal. Type in  
`ssh root@` and then go to the menu bar and select edit -> paste (the IP address).  
`The authenticity of host 'x.x.x.x (x.x.x.x)' can't be established.  
ECDSA key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxx.  
Are you sure you want to continue connecting (yes/no)? yes` Type in yes here  
`root@x.x.x.x's password: `  
Go back to the vultr manage webpage and under password click the copy icon 
![copy icon](https://www.materialui.co/materialIcons/content/content_copy_black_24x24.png "copy icon")  
Back on the Terminal screen paste in the password and press enter.  

</details>

___
