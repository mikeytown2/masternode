#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/ccbcd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='CryptoCashBack-Hub/CCBC'
# Display Name.
DAEMON_NAME='CCBC Core'
# Coin Ticker.
TICKER='CCBC'
# Binary base name.
BIN_BASE='ccbc'
# Directory.
DIRECTORY='.ccbc'
# Conf File.
CONF='ccbc.conf'
# Port.
DEFAULT_PORT=5520
# Explorer URL.
EXPLORER_URL='https://explorer.ccbcoin.club/'
# Rate limit explorer.
EXPLORER_SLEEP=1
EXPLORER_RAWTRANSACTION_PATH='api/tx/'
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
EXPLORER_GETADDRESS_PATH='ext/getbalance'
# Amount of Collateral needed.
COLLATERAL=25000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='SMvb8FegSzgk9wbWirEUkjTLWnk3WcmeyS'
# Dropbox Addnodes.
DROPBOX_ADDNODES='fde9f8qiltxasj4'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='houas85737qpnzj'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='kanzj13p51g3tkr'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "CCBC"
  ____ ____ ____   ____    ____
 / ___/ ___| __ ) / ___|  / ___|___  _ __ ___
| |  | |   |  _ \| |     | |   / _ \| '__/ _ \
| |__| |___| |_) | |___  | |__| (_) | | |  __/
 \____\____|____/ \____|  \____\___/|_|  \___|

CCBC
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

