#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/pepecoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='pepeteam/pepecoin'
# Display Name.
DAEMON_NAME='PepeCoin /'
# Coin Ticker.
TICKER='PEPE'
# Binary base name.
BIN_BASE='pepecoin'
# Directory.
DIRECTORY='.pepecoin'
# Conf File.
CONF='pepecoin.conf'
# Port.
DEFAULT_PORT=29377
# Explorer URL.
EXPLORER_URL='http://explorer.memetic.ai/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=15000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD='http://seed2.pepecoin.co/wallets/2.9.1.0/linux/pepecoind'
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1

# Control Binary.
CONTROLLER_BIN='pepecoind'

# Tip Address.
TIPS='PH3k1EXYV6AkqtC9wwDbgBWdaftKAStrAB'
# Dropbox Addnodes.
DROPBOX_ADDNODES='71t47fhow9hpxh0'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='pa07tjmyct2jrop'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='me82f6kkq9qz647'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "PEPECOIN"
 ____                  ____      _            __
|  _ \ ___ _ __   ___ / ___|___ (_)_ __      / /
| |_) / _ \ '_ \ / _ \ |   / _ \| | '_ \    / / 
|  __/  __/ |_) |  __/ |__| (_) | | | | |  / /  
|_|   \___| .__/ \___|\____\___/|_|_| |_| /_/   
          |_|                                   

PEPECOIN
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

