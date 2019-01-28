#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stoned.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='stonecoinproject/Stonecoin'
# Display Name.
DAEMON_NAME='Stone Core'
# Coin Ticker.
TICKER='STON'
# Binary base name.
BIN_BASE='stone'
# Directory.
DIRECTORY='.stonecore'
# Conf File.
CONF='stone.conf'
# Port.
DEFAULT_PORT=22329
# Explorer URL.
EXPLORER_URL='http://explorer.stonecoin.rocks/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1500
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD='https://www.dropbox.com/s/8uuyusgng094sfg/stone.zip?dl=1'
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1

# Tip Address.
TIPS='SXFprY61swBuDkRtwjGo152dcH9RaiN8eG'
# Dropbox Addnodes.
DROPBOX_ADDNODES='kzv7hany0eizn6f'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='vbmh8i69vzyom3i'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='8qj830od1gtn4xl'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "STONE"
 ____  _                      ____               
/ ___|| |_ ___  _ __   ___   / ___|___  _ __ ___ 
\___ \| __/ _ \| '_ \ / _ \ | |   / _ \| '__/ _ \
 ___) | || (_) | | | |  __/ | |__| (_) | | |  __/
|____/ \__\___/|_| |_|\___|  \____\___/|_|  \___|

STONE
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

