#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/innovad.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='innovacoin/innova'
# Display Name.
DAEMON_NAME='Innova Core'
# Coin Ticker.
TICKER='INNO'
# Binary base name.
BIN_BASE='innova'
# Directory.
DIRECTORY='.innovacore'
# Conf File.
CONF='innova.conf'
# Port.
DEFAULT_PORT=14520
# Explorer URL.
EXPLORER_URL='http://explorer.innovacoin.info/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3

SENTINEL_GITHUB='https://github.com/innovacoin/sentinel.git'
SENTINEL_CONF_START="innova_conf"

# Tip Address.
TIPS='iKYsvR2aXru92ceLVzqCUMuNC6Wk5nXqsP'
# Dropbox Addnodes.
DROPBOX_ADDNODES='nty40t9rw8gfosv'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='bsrxjbi7nirswfz'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='kz3piwmvikivx4x'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "INNOVA"
 ___                                ____
|_ _|_ __  _ __   _____   ____ _   / ___|___  _ __ ___
 | || '_ \| '_ \ / _ \ \ / / _` | | |   / _ \| '__/ _ \
 | || | | | | | | (_) \ V / (_| | | |__| (_) | | |  __/
|___|_| |_|_| |_|\___/ \_/ \__,_|  \____\___/|_|  \___|

INNOVA
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
