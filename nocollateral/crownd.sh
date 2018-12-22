#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/crownd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='Crowndev/crown-core'
# Display Name.
DAEMON_NAME='Crown Core'
# Coin Ticker.
TICKER='CRW'
# Binary base name.
BIN_BASE='crown'
# Directory.
DIRECTORY='.crown'
# Conf File.
CONF='crown.conf'
# Port.
DEFAULT_PORT=9340
# Explorer URL.
EXPLORER_URL='https://chainz.cryptoid.info/crw/'
# Set the endpoint for getting info from the explorer.
EXPLORER_BLOCKCOUNT_PATH='api.dws?q=getblockcount'
EXPLORER_BLOCKCOUNT_OFFSET='+1'
EXPLORER_RAWTRANSACTION_PATH='crw/api.dws?q=txinfo&t='
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
EXPLORER_GETADDRESS_PATH='crw/api.dws?key=62f6b161a9a5&q=getbalance&a='
MASTERNODE_GENKEY_COMMAND='node genkey'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=10000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3


# Dropbox Addnodes
DROPBOX_ADDNODES='3kmwvwnyh7umh69'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='q7gsscg497gxp7o'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='h5w7e93o9308xw7'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "CROWN"
  ____                            ____
 / ___|_ __ _____      ___ __    / ___|___  _ __ ___
| |   | '__/ _ \ \ /\ / / '_ \  | |   / _ \| '__/ _ \
| |___| | | (_) \ V  V /| | | | | |__| (_) | | |  __/
 \____|_|  \___/ \_/\_/ |_| |_|  \____\___/|_|  \___|

CROWN
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

