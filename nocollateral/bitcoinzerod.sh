#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/bitcoinzerod.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='BitcoinZeroOfficial/bitcoinzero'
# Display Name.
DAEMON_NAME='BitcoinZero'
# Coin Ticker.
TICKER='BZX'
# Binary base name.
BIN_BASE='bitcoinzero'
# Directory.
DIRECTORY='.bitcoinzero'
# Conf File.
CONF='bitcoinzero.conf'
# Port.
DEFAULT_PORT=29301
# Explorer URL.
EXPLORER_URL=''
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=45000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3
MASTERNODE_CALLER='bznode'
MASTERNODE_PREFIX='bzn'


# Tip Address.
TIPS='XWo9MyN7xqrzPGHkei3Nk6EpJ627BVE7xt'
# Dropbox Addnodes.
DROPBOX_ADDNODES='m17iyozg7mf9py4'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='vc3dewj28gpyec1'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='deghlfyohd3r6yz'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "BITCOINZERO"
 ____
| __ )______  __
|  _ \_  /\ \/ /
| |_) / /  >  <
|____/___|/_/\_\


BITCOINZERO
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
  wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/6c7d9b7c8cad8cf0831686bd50a917cac4172133/mcarper.sh -O ~/___mn.sh
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

