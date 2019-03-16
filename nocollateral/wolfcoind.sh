#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/wolfcoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='WolfpackBOT/Wolfcoin'
# Display Name.
DAEMON_NAME='Wolf WolfpackBOT/Wolfcoin'
# Coin Ticker.
TICKER='WOLF'
# Binary base name.
BIN_BASE='wolfcoin'
# Directory.
DIRECTORY='.wolfcoin'
# Conf File.
CONF='wolfcoin.conf'
# Port.
DEFAULT_PORT=4836
# Explorer URL.
EXPLORER_URL='http://blockexplorer.wolfpackbot.com/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=10000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3

# Sentinel Info.
SENTINEL_GITHUB='WolfpackBOT/sentinel'
SENTINEL_CONF_START='wolfcoin_conf'

# Tip Address.
TIPS='WUk7XZa9XL3mxG8L91AdNQFPUg8pbw6qbo'
# Dropbox Addnodes.
DROPBOX_ADDNODES='9srmhvzq7spxfea'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='1dc0x4klr8fi1ok'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='28xwrjta2zzldk5'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "WOLFCOIN"
__        __    _  __ 
\ \      / /__ | |/ _|
 \ \ /\ / / _ \| | |_ 
  \ V  V / (_) | |  _|
   \_/\_/ \___/|_|_|  
__        __    _  __                  _    ____   ___ _____  ____        __
\ \      / /__ | |/ _|_ __   __ _  ___| | _| __ ) / _ \_   _|/ /\ \      / /
 \ \ /\ / / _ \| | |_| '_ \ / _` |/ __| |/ /  _ \| | | || | / /  \ \ /\ / / 
  \ V  V / (_) | |  _| |_) | (_| | (__|   <| |_) | |_| || |/ /    \ V  V /  
   \_/\_/ \___/|_|_| | .__/ \__,_|\___|_|\_\____/ \___/ |_/_/      \_/\_/   
                     |_|                                                    
       _  __           _       
  ___ | |/ _| ___ ___ (_)_ __  
 / _ \| | |_ / __/ _ \| | '_ \ 
| (_) | |  _| (_| (_) | | | | |
 \___/|_|_|  \___\___/|_|_| |_|

WOLFCOIN
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

