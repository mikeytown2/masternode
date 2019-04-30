#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/swyftd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='SatoshiCoin-Crypto/SatoshiCoin-rebrand'
# Display Name.
DAEMON_NAME='SWYFT.Network Wallet'
# Coin Ticker.
TICKER='SATC'
# Binary base name.
BIN_BASE='swyft'
# Directory.
DIRECTORY='.swyft'
# Conf File.
CONF='swyft.conf'
# Port.
DEFAULT_PORT=3877
# Explorer URL.
EXPLORER_URL='https://explorer.satoshicoin.world/'
EXPLORER_BLOCKCOUNT_PATH=''
EXPLORER_RAWTRANSACTION_PATH=''
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
EXPLORER_GETADDRESS_PATH=''
EXPLORER_BLOCKCOUNT_OFFSET='+0'
BAD_SSL_HACK='--no-check-certificate'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL='10000
100000'
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='SVyjstFCYYT33PbqvTsvhp5qVDnBLjWCgr'
# Dropbox Addnodes.
DROPBOX_ADDNODES='tf6i2fuw3pp1o37'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='qaznjji5zsadptd'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='xrifr62132f80p7'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "SWYFT"
 ______        ____   _______ _____ _   _      _                      _
/ ___\ \      / /\ \ / /  ___|_   _| \ | | ___| |___      _____  _ __| | __
\___ \\ \ /\ / /  \ V /| |_    | | |  \| |/ _ \ __\ \ /\ / / _ \| '__| |/ /
 ___) |\ V  V /    | | |  _|   | |_| |\  |  __/ |_ \ V  V / (_) | |  |   <
|____/  \_/\_/     |_| |_|     |_(_)_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\
__        __    _ _      _
\ \      / /_ _| | | ___| |_
 \ \ /\ / / _` | | |/ _ \ __|
  \ V  V / (_| | | |  __/ |_
   \_/\_/ \__,_|_|_|\___|\__|

SWYFT
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

