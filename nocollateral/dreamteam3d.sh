#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/dreamteam3d.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='DreamTeamCoin3/dreamteam3'
# Display Name.
DAEMON_NAME='DreamTeam3 Core'
# Coin Ticker.
TICKER='DREA'
# Binary base name.
BIN_BASE='dreamteam3'
# Directory.
DIRECTORY='.dt3'
# Conf File.
CONF='dreamteam3.conf'
# Port.
DEFAULT_PORT=17123
# Explorer URL.
EXPLORER_URL='http://95.179.133.32:81/'
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
TIPS='3D3mEU2mf2inJfd6bL15daK2gtJhJP9176'
# Dropbox Addnodes.
DROPBOX_ADDNODES='tyuxmgafb96n34c'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='a7icgrinrp34xhm'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='x19u8cc5l1tuw8d'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "DREAMTEAM3"
 ____                         _____                    _____
|  _ \ _ __ ___  __ _ _ __ __|_   _|__  __ _ _ __ ___ |___ /
| | | | '__/ _ \/ _` | '_ ` _ \| |/ _ \/ _` | '_ ` _ \  |_ \
| |_| | | |  __/ (_| | | | | | | |  __/ (_| | | | | | |___) |
|____/|_|  \___|\__,_|_| |_| |_|_|\___|\__,_|_| |_| |_|____/

DREAMTEAM3
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
  wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/6c7d9b7c8cad8cf0831686bd50a917cac4172133/mcarper.sh -O ~/___mn.sh
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

