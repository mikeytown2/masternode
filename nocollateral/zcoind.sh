#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/zcoind.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='zcoinofficial/zcoin'
# Display Name.
DAEMON_NAME='ZCoin'
# Coin Ticker.
TICKER='XZC'
# Binary base name.
BIN_BASE='zcoin'
# Directory.
DIRECTORY='.zcoin'
# Conf File.
CONF='zcoin.conf'
# Port.
DEFAULT_PORT=8168
# Explorer URL
EXPLORER_URL='https://xzc.ccore.online/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=1000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3
MASTERNODE_CALLER='znode'
MASTERNODE_PREFIX='zn'
# Username Prefix.
DAEMON_PREFIX='znode'

# Tip Address
TIPS=''
# Dropbox Addnodes
DROPBOX_ADDNODES='my9oy3t39358ibq'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='xi4qekkovr4h321'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='8fh4nwdk9qy1fan'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "ZCOIN"

Z""""""""`Z                   oo
Z ZZZZ   .Z
Z  ZP  .ZZZ .d8888b. .d8888b. dP 88d888b.
ZZP  .ZZ  Z 88'  `"" 88'  `88 88 88'  `88
Z' .ZZZZZ Z 88.  ... 88.  .88 88 88    88
Z         Z `88888P' `88888P' dP dP    dP
ZZZZZZZZZZZ

ZCOIN
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
