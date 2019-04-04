#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/gpcd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='greenpaycoin/GreenPayCoin'
# Display Name.
DAEMON_NAME='GreenPayCoin Wallet'
# Coin Ticker.
TICKER='GPC'
# Binary base name.
BIN_BASE='gpc'
# Directory.
DIRECTORY='.gpc'
# Conf File.
CONF='gpc.conf'
# Port.
DEFAULT_PORT=38797
# Explorer URL.
EXPLORER_URL=''
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
TIPS='Gh7d6xekq1VwbB2iQ1FNgvhR6SeGk2eASw'
# Dropbox Addnodes.
DROPBOX_ADDNODES='mur40t10tahd319'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='tltnaxlumjjs4pt'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='ddzrcx0kljud0x8'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "GPC"
   ___  ____   ____  ____ __  __ ____   ___  _  _   ___   ___   __ __  __
  // \\ || \\ ||    ||    ||\ || || \\ // \\ \\//  //    // \\  || ||\ ||
 (( ___ ||_// ||==  ||==  ||\\|| ||_// ||=||  )/  ((    ((   )) || ||\\||
  \\_|| || \\ ||___ ||___ || \|| ||    || || //    \\__  \\_//  || || \||

GPC
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
  wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
  COUNTER=$(( COUNTER + 1 ))
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

