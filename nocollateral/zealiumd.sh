#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/zealiumd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='zealiumcoin/Zealium'
# Display Name.
DAEMON_NAME='Zealium'
# Coin Ticker.
TICKER='NZL'
# Binary base name.
BIN_BASE='zealium'
# Directory.
DIRECTORY='.zealium'
# Conf File.
CONF='zealium.conf'
# Port.
DEFAULT_PORT=31090
# Explorer URL.
EXPLORER_URL='https://explorer.zealium.co.nz/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=4000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='ZPJQG3hdvdkodn1hE4twuF3YmzYgTdpbVg'
# Dropbox Addnodes.
DROPBOX_ADDNODES='ajwbqt9msmrcj44'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='4xosn44oip400t0'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='7jt11l0gbdcz8mn'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ZEALIUM"
 _____          _ _                 
|__  /___  __ _| (_)_   _ _ __ ___  
  / // _ \/ _` | | | | | | '_ ` _ \ 
 / /|  __/ (_| | | | |_| | | | | | |
/____\___|\__,_|_|_|\__,_|_| |_| |_|

ZEALIUM
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
  wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
  COUNTER=$(( COUNTER + 1 ))
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

