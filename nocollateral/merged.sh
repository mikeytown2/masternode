#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/merged.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='ProjectMerge/merge'
# Display Name.
DAEMON_NAME='Merge Core'
# Coin Ticker.
TICKER='MERG'
# Binary base name.
BIN_BASE='merge'
# Directory.
DIRECTORY='.merge'
# Conf File.
CONF='merge.conf'
# Port.
DEFAULT_PORT=52000
# Explorer URL.
EXPLORER_URL='https://explorer.projectmerge.org/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=10000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=1

EXPLORER_BLOCKCOUNT_PATH='api_fetch.php?method=getblockcount'
EXPLORER_RAWTRANSACTION_PATH='api_fetch.php?method=gettransaction&txid='
EXPLORER_RAWTRANSACTION_PATH_SUFFIX=' '
EXPLORER_GETADDRESS_PATH='api_fetch.php?method=getbalance&address='

# Tip Address.
TIPS='MPArbwxUyqUyKNCMt6RNEdHeZNhTWJTYZj'
# Dropbox Addnodes.
DROPBOX_ADDNODES='e3f0czfwpis141p'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='ipfau712tiwyqx4'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='vt9h2o6vrw6df8y'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "MERGE"
 __  __                        ____
|  \/  | ___ _ __ __ _  ___   / ___|___  _ __ ___
| |\/| |/ _ \ '__/ _` |/ _ \ | |   / _ \| '__/ _ \
| |  | |  __/ | | (_| |  __/ | |__| (_) | | |  __/
|_|  |_|\___|_|  \__, |\___|  \____\___/|_|  \___|
                 |___/

MERGE
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

