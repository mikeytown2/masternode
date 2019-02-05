#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/qmcd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='project-qmc/QMC'
# Explorer URL
EXPLORER_URL='https://api.chainmapper.com/qmc/'
# Rate limit explorer
EXPLORER_SLEEP=1
EXPLORER_BLOCKCOUNT_PATH='getblockcount'
#EXPLORER_RAWTRANSACTION_PATH='getrawtransaction?txid='
EXPLORER_RAWTRANSACTION_PATH=' '
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
EXPLORER_GETADDRESS_PATH='getbalance/'
# Directory
DIRECTORY='.qmc'
# Binary base name.
BIN_BASE='qmc'
# Port
DEFAULT_PORT=28443
# Conf File
CONF='qmc.conf'
# Display Name
DAEMON_NAME='QMCoin'
# Coin Ticker
TICKER='QMC'
# Amount of Collateral needed
COLLATERAL=3600
COLLATERAL_ALT=$( timeout 5s wget -4qO- -T 3 -t 2 -o- "${EXPLORER_URL}getrawinfo" )
if [[ ! -z "${COLLATERAL_ALT}" ]]
then
  COLLATERAL=$( echo "${COLLATERAL_ALT}" | grep -io 'MN collateral":[0-9]*' | cut -d ':' -f2 | sed 's/ //g' |  sed 's/,//g' )
fi
# Fallback Blockcount
BLOCKCOUNT_FALLBACK_VALUE=59000
# Multiple on single IP.
MULTI_IP_MODE=3
# Can use IPv6.
IPV6=1

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "QMCoin"
 _      _
/ \|\/|/  _ o._
\_X|  |\_(_)|| |

QMCoin
}

# Tip Address
TIPS='Qji2oZBD2QzZ3Nk5q4ickFpDYfSLSAtG5q'
# Dropbox Addnodes
DROPBOX_ADDNODES='xbgib98dzd005df'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='0yz7z1zt6752rr2'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='gckue7v4ytq791c'

# Discord User Info
# @mcarper#0918
# 401161988744544258
cd ~/ || exit
COUNTER=0
PROJECT_DIR=$( basename "${GITHUB_REPO}" )
rm -rf "/var/multi-masternode-data/${PROJECT_DIR}/"
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

# shellcheck disable=SC1091
# shellcheck source=/root/___mn.sh
. ~/___mn.sh
DAEMON_SETUP_THREAD
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
