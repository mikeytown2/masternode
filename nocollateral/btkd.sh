#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/btkd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='bitcoin-token/Bitcoin-Turbo-Koin-Core'
# Display Name.
DAEMON_NAME='BTK Core'
# Coin Ticker.
TICKER='BTK'
# Binary base name.
BIN_BASE='btk'
# Directory.
DIRECTORY='.btk'
# Conf File.
CONF='btk.conf'
# Port.
DEFAULT_PORT=61472
# Explorer URL.
EXPLORER_URL='http://explorer.bitcointurbokoin.com/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=20000000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='Bb1X9m5QMqDUwKzGsLmcJ5R3BeWWEacPRz'
# Dropbox Addnodes.
DROPBOX_ADDNODES='bcnmblh580sjiyj'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='s8clyzw3oyvo6rg'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='utls7g2l1wip6d1'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "BTK"
 ____ _____ _  __   ____
| __ )_   _| |/ /  / ___|___  _ __ ___
|  _ \ | | | ' /  | |   / _ \| '__/ _ \
| |_) || | | . \  | |__| (_) | | |  __/
|____/ |_| |_|\_\  \____\___/|_|  \___|

BTK
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

