#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/rupayad.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='rupaya-project/rupx'
# Display Name.
DAEMON_NAME='Rupaya Core'
# Coin Ticker.
TICKER='RUPX'
# Binary base name.
BIN_BASE='rupaya'
# Directory.
DIRECTORY='.rupayacore'
# Conf File.
CONF='rupaya.conf'
# Port.
DEFAULT_PORT=9020
# Explorer URL.
EXPLORER_URL='https://find.rupx.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=20000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=0
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='RDgfvEgNfBQF6SH28GBHWshqikeaMoXpmB'
# Dropbox Addnodes.
DROPBOX_ADDNODES='5001y6b0g3zo6xr'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='195tf3z7n6k2kr3'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='aaxjj9qwbymh2nv'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "RUPAYA"
 ____                                   ____               
|  _ \ _   _ _ __   __ _ _   _  __ _   / ___|___  _ __ ___ 
| |_) | | | | '_ \ / _` | | | |/ _` | | |   / _ \| '__/ _ \
|  _ <| |_| | |_) | (_| | |_| | (_| | | |__| (_) | | |  __/
|_| \_\\__,_| .__/ \__,_|\__, |\__,_|  \____\___/|_|  \___|
            |_|          |___/                             

RUPAYA
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

