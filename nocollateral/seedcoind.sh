#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/seedcoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='seedcoinfoundation/seedcoin'
# Display Name.
DAEMON_NAME='Seedcoin Wallet'
# Coin Ticker.
TICKER='XSD'
# Binary base name.
BIN_BASE='Seedcoin'
# Directory.
DIRECTORY='.Seedcoin'
# Conf File.
CONF='Seedcoin.conf'
# Port.
DEFAULT_PORT=31821
# Explorer URL.
EXPLORER_URL='http://explorer.seed-coin.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=50000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3
# Control Binary.
CONTROLLER_BIN='Seedcoind'

# Dropbox Addnodes
DROPBOX_ADDNODES='9i428u7xj483fhk'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='x6h3p6ek1qt04ys'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='ba7pqyncmskjkpt'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "SEEDCOIN"
 ____                _           _        __        __    _ _      _
/ ___|  ___  ___  __| | ___ ___ (_)_ __   \ \      / /_ _| | | ___| |_
\___ \ / _ \/ _ \/ _` |/ __/ _ \| | '_ \   \ \ /\ / / _` | | |/ _ \ __|
 ___) |  __/  __/ (_| | (_| (_) | | | | |   \ V  V / (_| | | |  __/ |_
|____/ \___|\___|\__,_|\___\___/|_|_| |_|    \_/\_/ \__,_|_|_|\___|\__|

SEEDCOIN
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

