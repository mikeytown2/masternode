#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/nodebased.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='NodeBaseCore/NodeBaseCoin'
# Display Name.
DAEMON_NAME='Nodebase Core'
# Coin Ticker.
TICKER='NDB'
# Binary base name.
BIN_BASE='nodebase'
# Directory.
DIRECTORY='.nodebase'
# Conf File.
CONF='nodebase.conf'
# Port.
DEFAULT_PORT=22001
# Explorer URL.
EXPLORER_URL='http://206.189.199.234:3001/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='Ceh9ftEkseHmioshP1m9xMvm2RW4H1cYPY'
# Dropbox Addnodes.
DROPBOX_ADDNODES='r5a8a9ru6z7p4e9'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='it6fhh0jbp9acb4'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='6dxs7zztfq57kus'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "NODEBASE"
 _   _           _      _                       ____
| \ | | ___   __| | ___| |__   __ _ ___  ___   / ___|___  _ __ ___
|  \| |/ _ \ / _` |/ _ \ '_ \ / _` / __|/ _ \ | |   / _ \| '__/ _ \
| |\  | (_) | (_| |  __/ |_) | (_| \__ \  __/ | |__| (_) | | |  __/
|_| \_|\___/ \__,_|\___|_.__/ \__,_|___/\___|  \____\___/|_|  \___|

NODEBASE
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

