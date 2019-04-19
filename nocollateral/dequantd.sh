#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/dequantd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='dequant-project/dequant'
# Display Name.
DAEMON_NAME='Dequant Core'
# Coin Ticker.
TICKER='DEQ'
# Binary base name.
BIN_BASE='dequant'
# Directory.
DIRECTORY='.dequant'
# Conf File.
CONF='dequant.conf'
# Port.
DEFAULT_PORT=2222
# Explorer URL.
EXPLORER_URL='http://80.211.108.235:3001/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=5000
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD=''
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1


# Tip Address.
TIPS='DAzi6DRWvJpG9U1e3aQc4pSZq5vsPe1Akk'
# Dropbox Addnodes.
DROPBOX_ADDNODES='l64atd5x6yxpy44'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='nt3bmxdsfq1052x'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='7yeve0qks08bdqs'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "DEQUANT"
 ____                               _      ____
|  _ \  ___  __ _ _   _  __ _ _ __ | |_   / ___|___  _ __ ___
| | | |/ _ \/ _` | | | |/ _` | '_ \| __| | |   / _ \| '__/ _ \
| |_| |  __/ (_| | |_| | (_| | | | | |_  | |__| (_) | | |  __/
|____/ \___|\__, |\__,_|\__,_|_| |_|\__|  \____\___/|_|  \___|
               |_|

DEQUANT
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
  wget -4qo- gist.githubusercontent.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
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

