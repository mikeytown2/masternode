#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/bitblocksd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='BitBlocksProject/BitBlocks'
# Display Name.
DAEMON_NAME='BitBlocks Core'
# Coin Ticker.
TICKER='BBK'
# Binary base name.
BIN_BASE='bitblocks'
# Directory.
DIRECTORY='.bitblocks'
# Conf File.
CONF='bitblocks.conf'
# Port.
DEFAULT_PORT=58697
# Explorer URL.
EXPLORER_URL='https://bbk.overemo.com/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=150000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='BCUEhpot1Un2trQm6kjKb1hd1FsK8B8HMH'
# Dropbox Addnodes.
DROPBOX_ADDNODES='tpqhm3xl2it0g9h'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='8qgmqt3ah4qep4z'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='gqsva34n5nuyldz'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "BITBLOCKS"
 ____  _ _   ____  _            _           ____               
| __ )(_) |_| __ )| | ___   ___| | _____   / ___|___  _ __ ___ 
|  _ \| | __|  _ \| |/ _ \ / __| |/ / __| | |   / _ \| '__/ _ \
| |_) | | |_| |_) | | (_) | (__|   <\__ \ | |__| (_) | | |  __/
|____/|_|\__|____/|_|\___/ \___|_|\_\___/  \____\___/|_|  \___|

BITBLOCKS
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
  wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
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

