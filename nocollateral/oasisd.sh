#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/oasisd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='OasisCoinTeam/Oasis'
# Display Name.
DAEMON_NAME='Oasis Core'
# Coin Ticker.
TICKER='OASI'
# Binary base name.
BIN_BASE='oasis'
# Directory.
DIRECTORY='.oasis'
# Conf File.
CONF='oasis.conf'
# Port.
DEFAULT_PORT=2358
# Explorer URL.
EXPLORER_URL='https://oasis.ccore.online/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=285
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='oMRU1srC5kxtWuXiWPsuPbVzgBdL15jTJV'
# Dropbox Addnodes.
DROPBOX_ADDNODES='4uv9579gevm5lhy'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='q8d2dfnup25d2fj'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='y19zhl71x3w4b4a'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "OASIS"
  ___            _        ____               
 / _ \  __ _ ___(_)___   / ___|___  _ __ ___ 
| | | |/ _` / __| / __| | |   / _ \| '__/ _ \
| |_| | (_| \__ \ \__ \ | |__| (_) | | |  __/
 \___/ \__,_|___/_|___/  \____\___/|_|  \___|

OASIS
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

