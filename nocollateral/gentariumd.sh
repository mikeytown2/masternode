#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/gentariumd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='genterium-project/gentarium-2.0'
# Display Name.
DAEMON_NAME='Gentarium Core'
# Coin Ticker.
TICKER='GTM'
# Binary base name.
BIN_BASE='gentarium'
# Directory.
DIRECTORY='.gentarium'
# Conf File.
CONF='gentarium.conf'
# Port.
DEFAULT_PORT=27117
# Explorer URL.
EXPLORER_URL='https://explorer.gtmcoin.io/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1

# Sentinel Info.
SENTINEL_GITHUB='genterium-project/sentinel'
SENTINEL_CONF_START='gentarium_conf'

# Tip Address.
TIPS='g5B2jCvYzpZLvEM4DU7KELKokd1Y4gJdJQ'
# Dropbox Addnodes.
DROPBOX_ADDNODES='j8skdnih6vjtofy'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='g0nhvu0yd04814l'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='0nkqaf7gp82ubd7'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "GENTARIUM"
  ____            _             _                    ____               
 / ___| ___ _ __ | |_ __ _ _ __(_)_   _ _ __ ___    / ___|___  _ __ ___ 
| |  _ / _ \ '_ \| __/ _` | '__| | | | | '_ ` _ \  | |   / _ \| '__/ _ \
| |_| |  __/ | | | || (_| | |  | | |_| | | | | | | | |__| (_) | | |  __/
 \____|\___|_| |_|\__\__,_|_|  |_|\__,_|_| |_| |_|  \____\___/|_|  \___|

GENTARIUM
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

