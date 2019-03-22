#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/gossipd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='GOSSIPCOIN/gossip'
# Display Name.
DAEMON_NAME='GOSSIP Core'
# Coin Ticker.
TICKER='GOSS'
# Binary base name.
BIN_BASE='gossip'
# Directory.
DIRECTORY='.gossip'
# Conf File.
CONF='gossip.conf'
# Port.
DEFAULT_PORT=23677
# Explorer URL.
EXPLORER_URL='https://explorer.gossipcoin.org/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=9999
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD='https://bitbucket.org/GOSSIPCOIN/gossip/downloads/gossip-2.0.0-x86_64-linux-complete.tar.xz'
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='GKsx4Gf1ZJe6Zz42Bvn39H5WAb6uVPf71C'
# Dropbox Addnodes.
DROPBOX_ADDNODES='kd4sbp9pmxh7254'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='yb52x6zd5vv487y'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='0cnh2j519yf6v8a'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "GOSSIP"
  ____  ___  ____ ____ ___ ____     ____
 / ___|/ _ \/ ___/ ___|_ _|  _ \   / ___|___  _ __ ___
| |  _| | | \___ \___ \| || |_) | | |   / _ \| '__/ _ \
| |_| | |_| |___) |__) | ||  __/  | |__| (_) | | |  __/
 \____|\___/|____/____/___|_|      \____\___/|_|  \___|

GOSSIP
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

