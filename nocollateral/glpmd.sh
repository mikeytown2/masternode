#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/glpmd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='GLPMCORE/GLPM'
# Display Name.
DAEMON_NAME='GLPM Core'
# Coin Ticker.
TICKER='GLPM'
# Binary base name.
BIN_BASE='GLPM'
# Directory.
DIRECTORY='.GLPM2'
# Conf File.
CONF='GLPM2.conf'
# Port.
DEFAULT_PORT=31999
# Explorer URL
EXPLORER_URL='http://glpm.dynu.net/'
# Amount of Collateral needed.
COLLATERAL=10000
# Blocktime in seconds.
BLOCKTIME=120
# Multiple on single IP.
MULTI_IP_MODE=1

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "GLACIER"
   ___ _            _               ___ _       _    __
  / _ \ | __ _  ___(_) ___ _ __    / _ \ | __ _| |_ / _| ___  _ __ _ __ ___
 / /_\/ |/ _` |/ __| |/ _ \ '__|  / /_)/ |/ _` | __| |_ / _ \| '__| '_ ` _ \
/ /_\\| | (_| | (__| |  __/ |    / ___/| | (_| | |_|  _| (_) | |  | | | | | |
\____/|_|\__,_|\___|_|\___|_|    \/    |_|\__,_|\__|_|  \___/|_|  |_| |_| |_|

GLACIER
}

# Tip Address
TIPS='GPzrjPZZzja7J2Yk8AqpHoi4XfwdaJmyvn'
# Dropbox Addnodes
DROPBOX_ADDNODES='w6fhrqegibu7fqq'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=0
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='ihs1lqnow2i79lq'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=0
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='rl6ig0syypq6bwf'

# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=1
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='4'
# Mini Monitor Queue Payouts.
MINI_MONITOR_MN_QUEUE=1
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

# shellcheck disable=SC1091
# shellcheck source=/root/___mn.sh
. ~/___mn.sh
DAEMON_SETUP_THREAD
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
