#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/worxd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='worxcoin/worx'
# Display Name.
DAEMON_NAME='Worx Coin'
# Coin Ticker.
TICKER='WORX'
# Binary base name.
BIN_BASE='worx'
# Directory.
DIRECTORY='.worx'
# Conf File.
CONF='worx.conf'
# Port.
DEFAULT_PORT=3300
# Explorer URL.
EXPLORER_URL='http://blocks.worxcoin.io/'
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
MULTI_IP_MODE=3


# Tip Address.
TIPS='Wj5SUhQtdF5QGG4vRFgLX48p4fQKSHmFNH'
# Dropbox Addnodes.
DROPBOX_ADDNODES='wvh0qabazg4n4nq'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='7ehchuolglc98hp'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='dmtt0qsdct4lxuw'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "WORX"
__        __                 ____      _
\ \      / /__  _ ____  __  / ___|___ (_)_ __
 \ \ /\ / / _ \| '__\ \/ / | |   / _ \| | '_ \
  \ V  V / (_) | |   >  <  | |__| (_) | | | | |
   \_/\_/ \___/|_|  /_/\_\  \____\___/|_|_| |_|

WORX
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

