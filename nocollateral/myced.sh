#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.


: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/myced.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='myceworld/myce'
# Display Name.
DAEMON_NAME='Myce myceworld/myce'
# Coin Ticker.
TICKER='myce'
# Binary base name.
BIN_BASE='myce'
# Directory.
DIRECTORY='.myce'
# Conf File.
CONF='myce.conf'
# Port.
DEFAULT_PORT=23511
# Explorer URL
EXPLORER_URL='https://explorer.myce.world/'
# Bad Explorer SSL.
BAD_SSL_HACK='--no-check-certificate'
# Rate limit explorer
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=100000
# Cycle Daemon on first start.
DAEMON_CYCLE=1

# Tip Address
TIPS='MRwqWT27m1WhpRR8XSHWvbcj7uetU8D3gD'
# Dropbox Addnodes
DROPBOX_ADDNODES='xdzoc7ntncapimr'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='e9zzivi3lhb3hxx'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='zsgq3ehhu13k1ew'

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
cat << "MYCE"
    ____
   ]()()[
 ___\__/___
|__|    |__|  __  ____     _______ ______
 |_|_/\_|_|  |  \/  \ \   / / ____|  ____|
 |_|____|_|  | \  / |\ \_/ / |    | |__
 \_|_||_|_/  | |\/| | \   /| |    |  __|
  _|_||_|_   | |  | |  | | | |____| |____
 |___||___|  |_|  |_|  |_|  \_____|______|

MYCE
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
