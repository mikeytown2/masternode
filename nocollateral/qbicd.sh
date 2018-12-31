#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/qbicd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='qbic-platform/qbic'
# Display Name.
DAEMON_NAME='Qbic Core'
# Coin Ticker.
TICKER='QBIC'
# Binary base name.
BIN_BASE='qbic'
# Directory.
DIRECTORY='.qbiccore'
# Conf File.
CONF='qbic.conf'
# Port.
DEFAULT_PORT=17195
# Explorer URL.
EXPLORER_URL='http://explorer.qbic.io:3001/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1000
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3

SENTINEL_GITHUB='https://github.com/qbic-platform/sentinel.git'
SENTINEL_CONF_START='qbic_conf'

# Tip Address.
TIPS='GPdd9wym69bPji1tjv2qaDWHhjCdk3nPB4'
# Dropbox Addnodes.
DROPBOX_ADDNODES='nazclfv6dcpq45u'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='km9e13qcpu5pwur'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='79lib5ya48873e5'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "QBIC"
  ___  _     _         ____
 / _ \| |__ (_) ___   / ___|___  _ __ ___
| | | | '_ \| |/ __| | |   / _ \| '__/ _ \
| |_| | |_) | | (__  | |__| (_) | | |  __/
 \__\_\_.__/|_|\___|  \____\___/|_|  \___|

QBIC
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
  wget -4qo- goo.gl/uQw9tz -O ~/___mn.sh
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
