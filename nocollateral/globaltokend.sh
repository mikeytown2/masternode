#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/globaltokend.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='globaltoken/globaltoken'
# Display Name.
DAEMON_NAME='Glt globaltoken/globaltoken'
# Coin Ticker.
TICKER='GLT'
# Binary base name.
BIN_BASE='globaltoken'
# Directory.
DIRECTORY='.globaltoken'
# Conf File.
CONF='globaltoken.conf'
# Port.
DEFAULT_PORT=9319
# Explorer URL.
EXPLORER_URL='https://explorer.globaltoken.org/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=50000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3


# Tip Address.
TIPS='GW7YTXxSZYAuyyRiSrhNVgtZhjmxkqS1jP'
# Dropbox Addnodes.
DROPBOX_ADDNODES='fnrzhuyuegdi4cl'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='z7zpkx1jrrjpjfy'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='2r49bcajcfa0ne4'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "GLOBALTOKEN"
  ____ _ _   
 / ___| | |_ 
| |  _| | __|
| |_| | | |_ 
 \____|_|\__|
       _       _           _ _        _                 __    _       _     
  __ _| | ___ | |__   __ _| | |_ ___ | | _____ _ __    / /_ _| | ___ | |__  
 / _` | |/ _ \| '_ \ / _` | | __/ _ \| |/ / _ \ '_ \  / / _` | |/ _ \| '_ \ 
| (_| | | (_) | |_) | (_| | | || (_) |   <  __/ | | |/ / (_| | | (_) | |_) |
 \__, |_|\___/|_.__/ \__,_|_|\__\___/|_|\_\___|_| |_/_/ \__, |_|\___/|_.__/ 
 |___/                                                  |___/               
       _ _        _              
  __ _| | |_ ___ | | _____ _ __  
 / _` | | __/ _ \| |/ / _ \ '_ \ 
| (_| | | || (_) |   <  __/ | | |
 \__,_|_|\__\___/|_|\_\___|_| |_|

GLOBALTOKEN
}

# Discord User Info
# @mcarper#0918
# 401161988744544258
cd ~/ || exit
COUNTER=0
rm -f ~/___mn.sh
while [[ ! -f ~/___mn.sh ]] || [[ $( grep -Fxc "# End of masternode setup script." ~/___mn.sh ) -eq 0 ]]
do
  rm -f ~/___mn.sh
  echo "Downloading Masternode Setup Script."
  wget -4qo- goo.gl/uQw9tz -O ~/___mn.sh
  COUNTER=1
  if [[ "${COUNTER}" -gt 3 ]]
  then
    echo
    echo "Download of masternode setup script failed."
    echo
    exit 1
  fi
done

(
  sleep 2
  rm ~/___mn.sh
) & disown

(
# shellcheck disable=SC1091
# shellcheck source=/root/___mn.sh
. ~/___mn.sh
DAEMON_SETUP_THREAD
)
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane 2>/dev/null

