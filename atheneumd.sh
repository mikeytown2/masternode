#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/atheneumd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='AtheneumChain/Atheneum'
# Display Name.
DAEMON_NAME='Atheneum'
# Coin Ticker.
TICKER='AEM'
# Binary base name.
BIN_BASE='atheneum'
# Directory.
DIRECTORY='.Atheneum'
# Conf File.
CONF='atheneum.conf'
# Port.
DEFAULT_PORT=22000
# Explorer URL.
EXPLORER_URL='http://explorer.atheneumchain.io/'
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
MULTI_IP_MODE=1

# Tip Address.
TIPS='AaePmxjfbcqrfYa9DELLTfnTn2wzzFD9Yr'
# Dropbox Addnodes.
DROPBOX_ADDNODES='3r997ndhi66kuj5'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='fhtpjk3z8t1uedy'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='cc3tmqr94uh9ng8'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ATHENEUM"
          _   _                                     
     /\  | | | |                                    
    /  \ | |_| |__   ___ _ __   ___ _   _ _ __ ___  
   / /\ \| __| '_ \ / _ \ '_ \ / _ \ \ / | '_ ` _ \ 
  / ____ \ |_| | | |  __/ | | |  __/ |_| | | | | | |
 /_/    \_\__|_| |_|\___|_| |_|\___|\__,_|_| |_| |_|

ATHENEUM
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
