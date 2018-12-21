#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/recod.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='rent-coin/RECO'
# Display Name.
DAEMON_NAME='RECO Core'
# Coin Ticker.
TICKER='RECO'
# Binary base name.
BIN_BASE='reco'
# Directory.
DIRECTORY='.reco'
# Conf File.
CONF='reco.conf'
# Port.
DEFAULT_PORT=34578
# Explorer URL
EXPLORER_URL='http://reco.resqchain.org:3001/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=2000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1

# Tip Address.
TIPS='scc86L3B6qWwbjL37GbogcwoRXnvKAZ6iW'
# Dropbox Addnodes
DROPBOX_ADDNODES='mc1dw3x76q1dvf5'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='qd4cxzpk1nd4t3l'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='0l2l88fx5z3hoez'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "RECO"
 ____  _____ ____ ___     ____
|  _ \| ____/ ___/ _ \   / ___|___  _ __ ___
| |_) |  _|| |  | | | | | |   / _ \| '__/ _ \
|  _ <| |__| |__| |_| | | |__| (_) | | |  __/
|_| \_\_____\____\___/   \____\___/|_|  \___|

RECO
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
