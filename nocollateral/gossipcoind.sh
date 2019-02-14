#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/gossipcoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='g0ssipcoin/GossipCoinCore'
# Display Name.
DAEMON_NAME='Gossipcoin Core'
# Coin Ticker.
TICKER='GOSS'
# Binary base name.
BIN_BASE='gossipcoin'
# Directory.
DIRECTORY='.gossipcoin'
# Conf File.
CONF='gossipcoin.conf'
# Port.
DEFAULT_PORT=22123
# Explorer URL
EXPLORER_URL='https://goss.ccore.online/'
# Rate limit explorer
EXPLORER_SLEEP=1
# Amount of Collateral needed
COLLATERAL=100000
if [ -x "$( command -v hxnormalize )" ]
then
  echo "Getting collateral from explorer"
  COLLATERAL_ALT=$( wget -4qO- -o- "${EXPLORER_URL}"/masternodes | hxnormalize -x | hxselect -i -c 'table tbody tr:nth-child(4) td:nth-child(2)' | grep -m 1 -o '[0-9]*' )
  if [[ ! -z "${COLLATERAL_ALT}" ]] && [[ "${COLLATERAL_ALT}" -gt "${COLLATERAL}" ]]
  then
    COLLATERAL=${COLLATERAL_ALT}
  fi
else
  COLLATERAL_ALT=$( wget -4qO- -o- "${EXPLORER_URL}"/masternodes | grep " ${TICKER}<br" | grep  -m 1 -o '[0-9]*' )
  if [[ ! -z "${COLLATERAL_ALT}" ]] && [[ "${COLLATERAL_ALT}" -gt "${COLLATERAL}" ]]
  then
    COLLATERAL=${COLLATERAL_ALT}
  fi
fi
# Multiple on single IP.
MULTI_IP_MODE=1
# Daemon can use IPv6.
IPv6=0

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "GOSSIPCOIN"
 //__    _____             _     _____     _       /\\    @
///,-   |   __|___ ___ ___|_|___|     |___|_|___   \/ |   `@
  ||)   |  |  | . |_ -|_ -| | . |   --| . | |   |   ~||   @`
  \\_, )|_____|___|___|___|_|  _|_____|___|_|_|_|   _|| `@
   `--'                     |_|                    /\ | @
                                                   \//@@`
GOSSIPCOIN
}

# Tip Address
TIPS='GciRiMuibYsaCJKHVNWjh1TPH9jz3U4T7d'
# Dropbox Addnodes
DROPBOX_ADDNODES='f2x1ng632abzy7e'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='f7byrr4avojncpv'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='flyt8k5m18as6gq'
# Fallback Blockcount
BLOCKCOUNT_FALLBACK_VALUE=280000

# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

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

(
# shellcheck disable=SC1091
# shellcheck source=/root/___mn.sh
. ~/___mn.sh
DAEMON_SETUP_THREAD
)
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
