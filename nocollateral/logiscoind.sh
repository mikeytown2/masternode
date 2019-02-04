#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/logiscoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='lgsproject/LogisCoin'
# Display Name.
DAEMON_NAME='LogisCoin Core'
# Coin Ticker.
TICKER='LGS'
# Binary base name.
BIN_BASE='logiscoin'
# Directory.
DIRECTORY='.logiscoin'
# Conf File.
CONF='logiscoin.conf'
# Port.
DEFAULT_PORT=48484
# Explorer URL.
EXPLORER_URL='http://explorer.logiscoin.cc/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='GRgF4tuxsxSc94eZ3PrhTd8mF1DUSSwid4'
# Dropbox Addnodes.
DROPBOX_ADDNODES='1zzyr8x5i7mgvy4'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='weth1xi47bujdhv'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='x36xfirbdvo2nnm'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "LOGISCOIN"
 _                _      ____      _          ____               
| |    ___   __ _(_)___ / ___|___ (_)_ __    / ___|___  _ __ ___ 
| |   / _ \ / _` | / __| |   / _ \| | '_ \  | |   / _ \| '__/ _ \
| |__| (_) | (_| | \__ \ |__| (_) | | | | | | |__| (_) | | |  __/
|_____\___/ \__, |_|___/\____\___/|_|_| |_|  \____\___/|_|  \___|
            |___/                                                

LOGISCOIN
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

