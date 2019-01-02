#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/kydd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='kydcoin/KYD3'
# Display Name.
DAEMON_NAME='KYD Core'
# Coin Ticker.
TICKER='KYD'
# Binary base name.
BIN_BASE='kyd'
# Directory.
DIRECTORY='.kydcore'
# Conf File.
CONF='kyd.conf'
# Port.
DEFAULT_PORT=12244
# Explorer URL.
EXPLORER_URL='https://explorer.kydcoin.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=10000
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='YS6Ey9x3cT1PqvqDCv7SFEym3XvHip5ENb'
# Dropbox Addnodes.
DROPBOX_ADDNODES='2seowrgt29a1q9q'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='7rzlojyy69fvafi'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='zlk5asb37yzg98a'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "KYD"
 _  ____   ______     ____
| |/ /\ \ / /  _ \   / ___|___  _ __ ___
| ' /  \ Y /| | | | | |   / _ \| '__/ _ \
| . \   | | | |_| | | |__| (_) | | |  __/
|_|\_\  |_| |____/   \____\___/|_|  \___|

KYD
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

