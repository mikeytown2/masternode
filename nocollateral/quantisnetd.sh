#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/quantisnetd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='QuantisDev/QuantisNet-Fork-New-Chain'
# Display Name.
DAEMON_NAME='QuantisNET Core'
# Coin Ticker.
TICKER='QUAN'
# Binary base name.
BIN_BASE='quantisnet'
# Directory.
DIRECTORY='.quantisnet'
# Conf File.
CONF='quantisnet.conf'
# Port.
DEFAULT_PORT=7771
# Explorer URL.
EXPLORER_URL='https://chain.quantisnetwork.org/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=5000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD='http://45.76.62.99/files/quantisnetd
http://45.76.62.99/files/quantisnet-cli'
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='qfnShrpBzpY9YGjixXQ7vP78Ync69Xbeue'
# Dropbox Addnodes.
DROPBOX_ADDNODES='91dabgg4a4timj4'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='ph0fs1n3pmvhfyn'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='v10qhjy1pdzsacg'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "QUANTISNET"
  ___                    _   _     _   _ _____ _____    ____
 / _ \ _   _  __ _ _ __ | |_(_)___| \ | | ____|_   _|  / ___|___  _ __ ___
| | | | | | |/ _` | '_ \| __| / __|  \| |  _|   | |   | |   / _ \| '__/ _ \
| |_| | |_| | (_| | | | | |_| \__ \ |\  | |___  | |   | |__| (_) | | |  __/
 \__\_\\__,_|\__,_|_| |_|\__|_|___/_| \_|_____| |_|    \____\___/|_|  \___|

QUANTISNET
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

