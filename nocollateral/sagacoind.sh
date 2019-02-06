#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/sagacoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='sagacrypto/SagaCoin'
# Display Name.
DAEMON_NAME='SagaCoin Wallet'
# Coin Ticker.
TICKER='SAGA'
# Binary base name.
BIN_BASE='sagacoin'
# Directory.
DIRECTORY='.SagaCoin'
# Conf File.
CONF='sagacoin.conf'
# Port.
DEFAULT_PORT=48744
# Explorer URL.
EXPLORER_URL='http://explorer.sagacoin.net/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=2500
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3
IPV6=1

# Control Binary.
CONTROLLER_BIN='sagacoind'

# Tip Address.
TIPS='sYy6XG6dP1Pm3sXoUb4ViaP6BQk5aQLr8Y'
# Dropbox Addnodes.
DROPBOX_ADDNODES='nigtp46rkij2ray'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='c3mipq1cze5w6cl'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='d9t1g8qo3clesgh'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "SAGACOIN"
 ____                     ____      _        __        __    _ _      _   
/ ___|  __ _  __ _  __ _ / ___|___ (_)_ __   \ \      / /_ _| | | ___| |_ 
\___ \ / _` |/ _` |/ _` | |   / _ \| | '_ \   \ \ /\ / / _` | | |/ _ \ __|
 ___) | (_| | (_| | (_| | |__| (_) | | | | |   \ V  V / (_| | | |  __/ |_ 
|____/ \__,_|\__, |\__,_|\____\___/|_|_| |_|    \_/\_/ \__,_|_|_|\___|\__|
             |___/                                                        

SAGACOIN
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

