#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/blocknoded.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='blocknodetech/blocknode'
# Display Name.
DAEMON_NAME='Blocknode Core'
# Coin Ticker.
TICKER='BND'
# Binary base name.
BIN_BASE='blocknode'
# Directory.
DIRECTORY='.blocknode'
# Conf File.
CONF='blocknode.conf'
# Port.
DEFAULT_PORT=37001
# Explorer URL.
EXPLORER_URL='https://explorer.blocknode.tech/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=100000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=120
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='BLUWs2FBrKf9Kj3FjbnYuyXaNPrWQqRKAm'
# Dropbox Addnodes.
DROPBOX_ADDNODES='1yfvk9we52zyv71'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='rdpaogisgdx1cgo'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='y60lfbubmh2a68v'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "BLOCKNODE"
 ____  _            _                    _         ____
| __ )| | ___   ___| | ___ __   ___   __| | ___   / ___|___  _ __ ___
|  _ \| |/ _ \ / __| |/ / '_ \ / _ \ / _` |/ _ \ | |   / _ \| '__/ _ \
| |_) | | (_) | (__|   <| | | | (_) | (_| |  __/ | |__| (_) | | |  __/
|____/|_|\___/ \___|_|\_\_| |_|\___/ \__,_|\___|  \____\___/|_|  \___|

BLOCKNODE
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

