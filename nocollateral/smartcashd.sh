#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/smartcashd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='SmartCash/Core-Smart'
# Explorer URL
EXPLORER_URL='https://smart.ccore.online/'
# Rate limit explorer
EXPLORER_SLEEP=1
# Fallback Blockcount
BLOCKCOUNT_FALLBACK_VALUE=726000
MASTERNODE_CALLER='smartnode'
MASTERNODE_PREFIX='sn'
DAEMON_PREFIX='smrt_sn'

ASCII_ART () {
echo -e "\\e[0m"
clear 2> /dev/null
cat << "SMARTCASH"
 _____                      _   _____           _
/  ___|                    | | /  __ \         | |
\ `--. _ __ ___   __ _ _ __| |_| /  \/ __ _ ___| |__
 `--. \ '_ ` _ \ / _` | '__| __| |    / _` / __| '_ \
/\__/ / | | | | | (_| | |  | |_| \__/\ (_| \__ \ | | |
\____/|_| |_| |_|\__,_|_|   \__|\____/\__,_|___/_| |_|

SMARTCASH
}

# Tip Address
TIPS='SUN5hNBXGLE2FGL6DmVb7ryYUuVneQuLG2'
# Dropbox Addnodes
DROPBOX_ADDNODES='c5nj9lrq22wgecy'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='bn7fg2vpu28bmdl'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='scjugxv8kco8z86'

# Multiple on single IP.
MULTI_IP_MODE=2
# Mini Monitor check masternode list.
MINI_MONITOR_MN_LIST=0
# Mini Monitor Status to check for.
MINI_MONITOR_MN_STATUS='Smartnode successfully started'
# Mini Monitor masternode count is a json string.
MINI_MONITOR_MN_COUNT_JSON=0

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
