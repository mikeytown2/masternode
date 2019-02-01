#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/adultchaind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='AdultChain/AdultChain'
# Display Name.
DAEMON_NAME='AdultChain Core'
# Coin Ticker.
TICKER='XXX'
# Binary base name.
BIN_BASE='adultchain'
# Directory.
DIRECTORY='.adultchain'
# Conf File.
CONF='adultchain.conf'
# Port.
DEFAULT_PORT=6969
# Explorer URL.
EXPLORER_URL='https://explorer.adultchain.xxx/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=20000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='XGbq7hm7TN4zTd5mAYpFPNbdCECpTkuZVu'
# Dropbox Addnodes.
DROPBOX_ADDNODES='w2ko8ljdrsck0p7'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='6nc1zrandbhxul0'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='2yy3c7wc2968r08'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ADULTCHAIN"
    _       _       _ _    ____ _           _          ____               
   / \   __| |_   _| | |_ / ___| |__   __ _(_)_ __    / ___|___  _ __ ___ 
  / _ \ / _` | | | | | __| |   | '_ \ / _` | | '_ \  | |   / _ \| '__/ _ \
 / ___ \ (_| | |_| | | |_| |___| | | | (_| | | | | | | |__| (_) | | |  __/
/_/   \_\__,_|\__,_|_|\__|\____|_| |_|\__,_|_|_| |_|  \____\___/|_|  \___|

ADULTCHAIN
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

