#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/altbetd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='altbet/abet'
# Display Name.
DAEMON_NAME='Altbet Core'
# Coin Ticker.
TICKER='ABET'
# Binary base name.
BIN_BASE='altbet'
# Directory.
DIRECTORY='.altbet'
# Conf File.
CONF='altbet.conf'
# Port.
DEFAULT_PORT=2238
# Explorer URL.
EXPLORER_URL='https://slaveexplorer.altbet.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='AQTYF6x2rrHAtUJ4zEVCXHvAjPYKZUN99x'
# Dropbox Addnodes.
DROPBOX_ADDNODES='ypuwi1pfmdb6lkw'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='1cbddho82jqq0qd'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='v1bg8tw5r7umbwn'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ALTBET"
    _    _ _   _          _      ____               
   / \  | | |_| |__   ___| |_   / ___|___  _ __ ___ 
  / _ \ | | __| '_ \ / _ \ __| | |   / _ \| '__/ _ \
 / ___ \| | |_| |_) |  __/ |_  | |__| (_) | | |  __/
/_/   \_\_|\__|_.__/ \___|\__|  \____\___/|_|  \___|

ALTBET
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

