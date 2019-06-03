#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# Run this file
# if skip_last_confirm is set use bash -c instead of bash -ic
# bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/catocoind.sh)" -- starting_username_number txhash outputindex genkey skip_last_confirm ; source ~/.bashrc
# screen -d -m bash -c "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/catocoind.sh)" -- -1 0 -1 -1 Y ; source ~/.bashrc
# bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/catocoind.sh)" ; source ~/.bashrc

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/catocoind.sh)" ; source ~/.bashrc
```

'

# Directory
DIRECTORY='.catocoin2'
# Port
DEFAULT_PORT=34888
# Conf File
CONF='catocoin2.conf'
# Display Name
DAEMON_NAME='CatoCoin'
# Github user and project.
GITHUB_REPO='CatoCoin/CatoCoin'
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD='https://github.com/CatoCoin/releases/raw/master/catocoin-linux-binaries.tar.gz'
# Binary base name.
BIN_BASE='catocoin'
# Explorer URL
EXPLORER_URL='http://explorer.catocoin.info/'
# Amount of Collateral needed
COLLATERAL='25000
50000
100000'
# Coin Ticker
TICKER='CATO'
# Multiple on single IP.
MULTI_IP_MODE=1

# Tip Address
TIPS='CbExC5RLwSghSNEq8pwDtiTS32Ngr8qquw'
# Dropbox Addnodes
DROPBOX_ADDNODES='8ejwde780f45q6u'
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='0qk6sxfx02eyi76'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='8gd968uig7skwb4'


ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "CATOCOIN"

 __         __
/   _ |_ _ /   _ . _
\__(_||_(_)\__(_)|| )


CATOCOIN
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
  COUNTER=$((COUNTER+1))
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

# shellcheck disable=SC1091
# shellcheck source=/root/___mn.sh
. ~/___mn.sh
DAEMON_SETUP_THREAD
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
