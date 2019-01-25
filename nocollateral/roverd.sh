#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/roverd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='RoverCoin/Rovercoin'
# Display Name.
DAEMON_NAME='Rover Wallet'
# Coin Ticker.
TICKER='ROE'
# Binary base name.
BIN_BASE='Rover'
# Directory.
DIRECTORY='.Rover'
# Conf File.
CONF='Rover.conf'
# Port.
DEFAULT_PORT=28218
# Explorer URL.
EXPLORER_URL='http://159.65.245.18:3001/'
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

# Control Binary.
CONTROLLER_BIN='Roverd'

# Tip Address.
TIPS='RSguE97VhWqA2ZFRYoPZ7m7NdM8X9qwBbK'
# Dropbox Addnodes.
DROPBOX_ADDNODES='y152cl4o6jkjfhy'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='wvyrao8pz88gv50'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='mhuhpf0o74bvt3e'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ROVER"
 ____                      __        __    _ _      _
|  _ \ _____   _____ _ __  \ \      / /_ _| | | ___| |_
| |_) / _ \ \ / / _ \ '__|  \ \ /\ / / _` | | |/ _ \ __|
|  _ < (_) \ V /  __/ |      \ V  V / (_| | | |  __/ |_
|_| \_\___/ \_/ \___|_|       \_/\_/ \__,_|_|_|\___|\__|

ROVER
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
. ~/1637d98130ac7dfbfa4d24bac0598107/mcarper.sh
DAEMON_SETUP_THREAD
)
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane 2>/dev/null

