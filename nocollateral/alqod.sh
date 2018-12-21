#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/alqod.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='ALQOCRYPTO/ALQO'
# Display Name.
DAEMON_NAME='ALQO Core'
# Coin Ticker.
TICKER='XLQ'
# Binary base name.
BIN_BASE='alqo'
# Directory.
DIRECTORY='.alqo'
# Conf File.
CONF='alqo.conf'
# Port.
DEFAULT_PORT=55500
# Explorer URL.
EXPLORER_URL='https://explorer.alqo.org/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Set the endpoint for getting info from the explorer.
EXPLORER_BLOCKCOUNT_PATH='api/blockcount'
EXPLORER_RAWTRANSACTION_PATH='api/transaction/'
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
EXPLORER_GETADDRESS_PATH='api/wallet/'
# Amount of Collateral needed.
COLLATERAL=10000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1

# Dropbox Addnodes.
DROPBOX_ADDNODES='35rugb2zmff7k3x'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='vp894lyddisxftu'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='okhuyk4lqz9twqa'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ALQO"
    _    _     ___   ___     ____
   / \  | |   / _ \ / _ \   / ___|___  _ __ ___
  / _ \ | |  | | | | | | | | |   / _ \| '__/ _ \
 / ___ \| |__| |_| | |_| | | |__| (_) | | |  __/
/_/   \_\_____\__\_\\___/   \____\___/|_|  \___|

ALQO
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
