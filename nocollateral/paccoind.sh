#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/paccoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='PACCommunity/PAC'
# Display Name.
DAEMON_NAME='$PAC Core'
# Coin Ticker.
TICKER='PAC'
# Binary base name.
BIN_BASE='paccoin'
# Directory.
DIRECTORY='.paccoincore'
# Conf File.
CONF='paccoin.conf'
# Port.
DEFAULT_PORT=7112
# Explorer URL.
EXPLORER_URL='http://explorer.paccoin.net/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=500000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3

# Sentinel Info.
SENTINEL_GITHUB='PACCommunity/sentinel'
SENTINEL_CONF_START='paccoin_conf'

# Tip Address.
TIPS='PXiyQ6CBEESJzmxWJXMBi9ZCy3Cihgh8Do'
# Dropbox Addnodes.
DROPBOX_ADDNODES='ti98j575kwnq27s'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='dswwefuk16033x4'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='cy4skpudznz0ymy'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "PACCOIN"
  _  ____   _    ____    ____               
 | ||  _ \ / \  / ___|  / ___|___  _ __ ___ 
/ __) |_) / _ \| |     | |   / _ \| '__/ _ \
\__ \  __/ ___ \ |___  | |__| (_) | | |  __/
(   /_| /_/   \_\____|  \____\___/|_|  \___|
 |_|                                        

PACCOIN
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

