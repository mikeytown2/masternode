1. Open wallet  
 - Unlock if it is locked
 
2. Create mn1 address in your wallet  
 - Top Menu File -> Receiving address -> New 
 - Call it mn1
 - Right click on mn1 and select "Copy address" 

3. Create collateral transaction 
 - Send Tab -> Pay To -> Paste in mn1 address 
 - In field "Amount" input Exactly the needed collateral 
 - Click the Send button

4. Get transaction id/hash 
 - Top menu 
 - Tools -> Debug console 
 - At the bottom type/paste in masternode outputs 
 - Copy the txhash line 

5. Get a VPS See https://github.com/mikeytown2/masternode/blob/master/VPS.md 

6. Copy masternode script and paste it into the putty console (right click is paste in putty). 

7. Edit masternode.conf on desktop wallet Copy (hightlight in putty) the last bold and underlined lines from the end of the script

       mn1_vultr.guest 1.2.3.4:5678 3BZ2gu8vNoZCb7s9LV4tLBJ8cvS8FeNiKmTYAgc85D6WqmBq5oD e9f43hfh3h3jmfgk9hkjklcnvbe84j60cv678lnbfgbd5532dk917cc 0
                      ^            ^                                                   ^                                                       ^

 - It should be all on one line and there should be a total of 4 spaces (marked with ^ above). 
 - If you can't open up the masternode.conf file
    - Windows: windows key + r `explorer %appdata%`  
      Mac: Finder -> Menubar (top of screen) -> Go -> Utilities, open Terminal, paste/type in `open ~/Library/Application\ Support/`
    - Go into the wallet's datadir
    - Find and open masternode.conf

8. Restart Desktop wallet and start mn 
 - Make sure the transcation is at least 16 blocks old otherwise it will not start correctly
 - Top menu 
 - Tools -> Debug console 
 - At the bottom type/paste in startmasternode alias false mn1_vultr.guest 
 - On the VPS it should popup saying that the mn has been started; it will tell you how long it will take to get your first reward.
