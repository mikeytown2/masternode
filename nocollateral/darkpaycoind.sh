#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/darkpaycoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='DarkPayCoin/darkpay'
# Display Name.
DAEMON_NAME='DARKPAYCOIN Core'
# Coin Ticker.
TICKER='DKPC'
# Binary base name.
BIN_BASE='darkpaycoin'
# Directory.
DIRECTORY='.darkpaycoin'
# Conf File.
CONF='darkpaycoin.conf'
# Port.
DEFAULT_PORT=6667
# Explorer URL.
EXPLORER_URL='http://explorer2.darkpaycoin.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Set the endpoint getting the rawtransaction.
EXPLORER_RAWTRANSACTION_PATH='api/tx/'
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
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
TIPS='DLsbP6oeJTJssMnt8mbRSV4Wqkg77wMraS'
# Dropbox Addnodes.
DROPBOX_ADDNODES='epxq8l99j9jynpq'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='hpcynqh3lw49dqz'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='m0picmiuxcszv8x'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "DARKPAYCOIN"
 ____    _    ____  _  ______   _ __   ______ ___ ___ _   _
|  _ \  / \  |  _ \| |/ /  _ \ / \\ \ / / ___/ _ \_ _| \ | |
| | | |/ _ \ | |_) | ' /| |_) / _ \\ V / |  | | | | ||  \| |
| |_| / ___ \|  _ <| . \|  __/ ___ \| || |__| |_| | || |\  |
|____/_/   \_\_| \_\_|\_\_| /_/   \_\_| \____\___/___|_| \_|
  ____
 / ___|___  _ __ ___
| |   / _ \| '__/ _ \
| |__| (_) | | |  __/
 \____\___/|_|  \___|

DARKPAYCOIN
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

