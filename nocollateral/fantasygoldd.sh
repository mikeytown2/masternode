#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/fantasygoldd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='FantasyGold/FantasyGold-Core'
# Display Name.
DAEMON_NAME='FantasyGold Core'
# Coin Ticker.
TICKER='FGC'
# Binary base name.
BIN_BASE='fantasygold'
# Directory.
DIRECTORY='.fantasygold'
# Conf File.
CONF='fantasygold.conf'
# Port.
DEFAULT_PORT=57810
# Explorer URL.
EXPLORER_URL='https://fantasygold.network/'
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


# Tip Address.
TIPS='FLJh5kay257WJaGJvSFtBZ8ZNuApBHHkB5'
# Dropbox Addnodes.
DROPBOX_ADDNODES='x1yq5dp8rkfsc8i'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='4w0jy8fg2gyc6ob'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='aielhkkyga3qsxm'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "FANTASYGOLD"
 _____           _                   ____       _     _    ____               
|  ___|_ _ _ __ | |_ __ _ ___ _   _ / ___| ___ | | __| |  / ___|___  _ __ ___ 
| |_ / _` | '_ \| __/ _` / __| | | | |  _ / _ \| |/ _` | | |   / _ \| '__/ _ \
|  _| (_| | | | | || (_| \__ \ |_| | |_| | (_) | | (_| | | |__| (_) | | |  __/
|_|  \__,_|_| |_|\__\__,_|___/\__, |\____|\___/|_|\__,_|  \____\___/|_|  \___|
                              |___/                                           

FANTASYGOLD
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

