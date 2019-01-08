#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/cardbuyersd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='CARDbuyers/BCARD'
# Display Name.
DAEMON_NAME='CARDbuyers Core'
# Coin Ticker.
TICKER='BCAR'
# Binary base name.
BIN_BASE='CARDbuyers'
# Directory.
DIRECTORY='.CARDbuyers'
# Conf File.
CONF='CARDbuyers.conf'
# Port.
DEFAULT_PORT=48451
# Explorer URL.
EXPLORER_URL='http://explorer.cardbuyers.cc:3001/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=5000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='B76HD2vojb2C7fCC5pCy2fYCrxQh4EzGNS'
# Dropbox Addnodes.
DROPBOX_ADDNODES='ayh0b67kwmihr9b'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='yi0rumgkhxs7bwx'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='zfab6q777dx2i0b'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "CARDBUYERS"
  ____    _    ____  ____  _                               
 / ___|  / \  |  _ \|  _ \| |__  _   _ _   _  ___ _ __ ___ 
| |     / _ \ | |_) | | | | '_ \| | | | | | |/ _ \ '__/ __|
| |___ / ___ \|  _ <| |_| | |_) | |_| | |_| |  __/ |  \__ \
 \____/_/   \_\_| \_\____/|_.__/ \__,_|\__, |\___|_|  |___/
                                       |___/               
  ____               
 / ___|___  _ __ ___ 
| |   / _ \| '__/ _ \
| |__| (_) | | |  __/
 \____\___/|_|  \___|

CARDBUYERS
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

