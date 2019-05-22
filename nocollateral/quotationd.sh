#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/quotationd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='QuotationCoin/QUOT-Coin'
# Display Name.
DAEMON_NAME='Quotation Core'
# Coin Ticker.
TICKER='QUOT'
# Binary base name.
BIN_BASE='quotation'
# Directory.
DIRECTORY='.quotation'
# Conf File.
CONF='quotation.conf'
# Port.
DEFAULT_PORT=19871
# Explorer URL
EXPLORER_URL='http://explorer.quotcoin.com/'
# Amount of Collateral needed.
COLLATERAL=5000
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address
TIPS='QTUfZ9pwka1nBigvVFnnwc59XG1YmoupPJ'
# Dropbox Addnodes
DROPBOX_ADDNODES='i5r3x3xb2la4gv4'
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='f3zdo679zotqxoh'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='fcujtw76kvd42hc'


ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "QUOTATION"
  ____            __       __  _
 / __ \__ _____  / /____ _/ /_(_)__  ___
/ /_/ / // / _ \/ __/ _ `/ __/ / _ \/ _ \
\___\_\_,_/\___/\__/\_,_/\__/_/\___/_//_/

QUOTATION
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
stty sane
