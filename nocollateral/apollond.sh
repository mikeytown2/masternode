#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/apollond.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='apollondeveloper/ApollonCore'
# Display Name.
DAEMON_NAME='Apollon Core'
# Coin Ticker.
TICKER='XAP'
# Binary base name.
BIN_BASE='apollon'
# Directory.
DIRECTORY='.ApollonCore'
# Conf File.
CONF='apollon.conf'
# Port.
DEFAULT_PORT=12218
# Explorer URL
EXPLORER_URL='https://explorer.apolloncoin.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=25000
# Blocktime in seconds.
BLOCKTIME=90
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Username Prefix.
DAEMON_PREFIX='apol_mn'
# Wait for MNSYNC.
MNSYNC_WAIT_FOR='"RequestedMasternodeAssets": 999,'
# Extra configuation for the conf file.
EXTRA_CONFIG='maxconnections=256'

# Tip Address
TIPS='AH8Rr4XHZHNzD6gGDj1vbip5jGVUFfS3k4'
# Dropbox Addnodes
DROPBOX_ADDNODES='imljen2mg6mlcok'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='n3lx3y28kqoq57n'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='n3oeymuneagala7'

# Multiple on single IP.
MULTI_IP_MODE=1
# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "APOLLON"

 ______                  ___    ___
/\  _  \                /\_ \  /\_ \
\ \ \A\ \  _____     ___\//\ \ \//\ \     ___     ___
 \ \  __ \/\ '__`\  / __`\\ \ \  \ \ \   / __`\ /' _ `\
  \ \ \/\ \ \ \A\ \/\ \A\ \\_\ \_ \_\ \_/\ \A\ \/\ \/\ \
   \ \_\ \_\ \ ,__/\ \____//\____\/\____\ \____/\ \_\ \_\
    \/_/\/_/\ \ \/  \/___/ \/____/\/____/\/___/  \/_/\/_/
             \ \_\
              \/_/

APOLLON
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
stty sane
