#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/coin2playd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='Coin2Play/c2pcore'
# Display Name.
DAEMON_NAME='Coin2Play Core'
# Coin Ticker.
TICKER='C2P'
# Binary base name.
BIN_BASE='coin2play'
# Directory.
DIRECTORY='.coin2play'
# Conf File.
CONF='coin2play.conf'
# Port.
DEFAULT_PORT=2221
# Explorer URL.
EXPLORER_URL='http://explorer.coin2play.io/'
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
IPV6=1

# Tip Address.
TIPS='c4aeUgvB8BLzBekpgv79P5K94YxKaoN7Q9'
# Dropbox Addnodes.
DROPBOX_ADDNODES='xuk23942qn3gj7h'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='l91vhvu892adees'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='blytapkp034ixh9'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "COIN2PLAY"
  ____      _       ____  ____  _                ____               
 / ___|___ (_)_ __ |___ \|  _ \| | __ _ _   _   / ___|___  _ __ ___ 
| |   / _ \| | '_ \  __) | |_) | |/ _` | | | | | |   / _ \| '__/ _ \
| |__| (_) | | | | |/ __/|  __/| | (_| | |_| | | |__| (_) | | |  __/
 \____\___/|_|_| |_|_____|_|   |_|\__,_|\__, |  \____\___/|_|  \___|
                                        |___/                       

COIN2PLAY
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

