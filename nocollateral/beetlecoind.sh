#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/beetlecoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='beetledev/Wallet'
# Display Name.
DAEMON_NAME='BeetleCoin Core'
# Coin Ticker.
TICKER='BEET'
# Binary base name.
BIN_BASE='beetlecoin'
# Directory.
DIRECTORY='.beetlecoin'
# Conf File.
CONF='beetlecoin.conf'
# Port.
DEFAULT_PORT=3133
# Explorer URL.
EXPLORER_URL='http://explore.beetlecoin.io/'
# Amount of Collateral needed.
COLLATERAL=150000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1

# Dropbox Addnodes
DROPBOX_ADDNODES='848kxejmn4ij9kc'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='fu97m0wdv5crsl3'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='fxywfb5w51yh8q5'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "BEETLECOIN"
 ____            _   _       ____      _          ____
| __ )  ___  ___| |_| | ___ / ___|___ (_)_ __    / ___|___  _ __ ___
|  _ \ / _ \/ _ \ __| |/ _ \ |   / _ \| | '_ \  | |   / _ \| '__/ _ \
| |_) |  __/  __/ |_| |  __/ |__| (_) | | | | | | |__| (_) | | |  __/
|____/ \___|\___|\__|_|\___|\____\___/|_|_| |_|  \____\___/|_|  \___|

BEETLECOIN
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

