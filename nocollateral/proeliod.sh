#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/proeliod.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='Proeliocoin/Source-Wallet'
# Display Name.
DAEMON_NAME='Proelio Core'
# Coin Ticker.
TICKER='PEO'
# Binary base name.
BIN_BASE='proelio'
# Directory.
DIRECTORY='.ProelioCore'
# Conf File.
CONF='proelio.conf'
# Port.
DEFAULT_PORT=5656
# Explorer URL.
EXPLORER_URL='https://explorer.proeliocoin.com/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=5000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='Psg6jBSnnin4xLy76vZuSH6yA4Ts1jX7zp'
# Dropbox Addnodes.
DROPBOX_ADDNODES='72jr7xpxr6g5zmk'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='qbgxbydsaf253cv'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='peql9ok7ev6h0td'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "PROELIO"
 ____                 _ _          ____               
|  _ \ _ __ ___   ___| (_) ___    / ___|___  _ __ ___ 
| |_) | '__/ _ \ / _ \ | |/ _ \  | |   / _ \| '__/ _ \
|  __/| | | (_) |  __/ | | (_) | | |__| (_) | | |  __/
|_|   |_|  \___/ \___|_|_|\___/   \____\___/|_|  \___|

PROELIO
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
  wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
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

