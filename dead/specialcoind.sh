#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/specialcoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='Specialcoindev/SPCC-CORE'
# Display Name.
DAEMON_NAME='SpecialCoin'
# Coin Ticker.
TICKER='SPCC'
# Binary base name.
BIN_BASE='specialcoin'
# Directory.
DIRECTORY='.specialcoin'
# Conf File.
CONF='specialcoin.conf'
# Port.
DEFAULT_PORT=21013
# Explorer URL
EXPLORER_URL='http://192.241.138.224:3003/'
# Amount of Collateral needed.
COLLATERAL=1000
# Number of Connections to wait for.
DAEMON_CONNECTIONS=2
# Cycle Daemon on first start.
DAEMON_CYCLE=1

# Tip Address
TIPS='CH6uZC2oudXtFYLriGgw6pcaRQ8uhQrcnQ'
# Dropbox Addnodes
DROPBOX_ADDNODES='gk6gw8vtrqc1b7r'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='5vrqt2t4cmwpd0h'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='8wi1qpbl4x1nmxn'

# Multiple on single IP.
MULTI_IP_MODE=1
# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=1

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "SPECIALCOIN"
                            _____                 _       _  _____      _
      ______ ______        / ____|               (_)     | |/ ____|    (_)
    _/      |      \_     | (___  _ __   ___  ___ _  __ _| | |     ___  _ _ __
   // ~~ ~~ | ~~ ~  \\     \___ \| '_ \ / _ \/ __| |/ _` | | |    / _ \| | '_ \
  // ~ ~ ~~ | ~~~ ~~ \\    ____) | |_) |  __/ (__| | (_| | | |___| (_) | | | | |
 //________.|.________\\  |_____/| .__/ \___|\___|_|\__,_|_|\_____\___/|_|_| |_|
'----------'-'----------'        | |
                                 |_|

SPECIALCOIN
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
