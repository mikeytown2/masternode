#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/energid.sh)" ; source ~/.bashrc
```

'

# Directory.
DIRECTORY='.energicore'
# Port.
DEFAULT_PORT=9797
# Conf File.
CONF='energi.conf'
# Display Name.
DAEMON_NAME='Energi Core'
# Github user and project.
GITHUB_REPO='energicryptocurrency/energi'
# Binary base name.
BIN_BASE='energi'
# Username Prefix.
DAEMON_PREFIX='enrg_mn'
# Explorer URL.
EXPLORER_URL='https://explore.energi.network/'
# Amount of Collateral needed.
COLLATERAL=10000
# Coin Ticker.
TICKER='NRG'
# Tip Address.
TIPS='EfQZJxx86Xa2DqzP9Hdgv7HQe1MtYzQpDC'
# Dropbox Addnodes.
DROPBOX_ADDNODES='ayu1r026swtmoat'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='j9wb0stn3c6nwyf'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='gsaqiry3h1ho3nh'
# Cycle Daemon.
DAEMON_CYCLE=0
# Slow Daemon Start.
SLOW_DAEMON_START=1
# Fallback Blockcount.
BLOCKCOUNT_FALLBACK_VALUE=450000
# Bad Explorer SSL.
BAD_SSL_HACK='--no-check-certificate'
# Extra configuation for the conf file.
EXTRA_CONFIG='maxconnections=24'
# Auto Recovery.
RESTART_IN_SYNC=0
# Multiple on single IP.
MULTI_IP_MODE=3
# Number of Connections to wait for.
DAEMON_CONNECTIONS=4
# Wait for MNSYNC
MNSYNC_WAIT_FOR='"AssetName": "MASTERNODE_SYNC_FINISHED"'

# Sentinel Info.
SENTINEL_GITHUB='https://github.com/energicryptocurrency/sentinel.git'
SENTINEL_CONF_START='energi_conf'

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "ENERGI"
      ___
     /\  \
    /::\  \
   /:/\:\__\
  /:/ /:/ _/_
 /:/ /:/ /\__\
 \:\ \/ /:/  /
  \:\  /:/  /   ____ __  __  ____ ____    ___  __
   \:\/:/  /   ||    ||\ || ||    || \\  // \\ ||
    \::/  /    ||==  ||\\|| ||==  ||_// (( ___ ||
     \/__/     ||___ || \|| ||___ || \\  \\_|| ||

ENERGI
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
