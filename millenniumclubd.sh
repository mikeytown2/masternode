#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/millenniumclubd.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='millenniumclub/MillenniumClubCoin'
# Display Name.
DAEMON_NAME='Millennium Club Core'
# Coin Ticker.
TICKER='MILL'
# Binary base name.
BIN_BASE='millenniumclub'
# Directory.
DIRECTORY='.millenniumclub'
# Conf File.
CONF='millenniumclub.conf'
# Port.
DEFAULT_PORT=5792
# Explorer URL.
EXPLORER_URL='http://explorer.millenniumclub.ca:3001/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=10000
# Direct Daemon Download if github has no releases.
#DAEMON_DOWNLOAD='https://millenniumclub.ca/beta/millenniumclubd
#https://millenniumclub.ca/beta/millenniumclub-cli'
# Blocktime in seconds.
BLOCKTIME=60
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3


# Tip Address.
TIPS='MBSFsmQdF7N4k67QmKGxJyT4wzi3TyGr39'
# Dropbox Addnodes.
DROPBOX_ADDNODES='xc0iqq328mh1pf5'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='ja7h8sk1q0sjmua'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='3jcqaipf7sl0xx6'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "QUANTISNET"
  __  __ _ _ _                  _                    _____ _       _
 |  \/  (_) | |                (_)                  / ____| |     | |
 | \  / |_| | | ___ _ __  _ __  _ _   _ _ __ ___   | |    | |_   _| |__
 | |\/| | | | |/ _ \ '_ \| '_ \| | | | | '_ ` _ \  | |    | | | | | '_ \
 | |  | | | | |  __/ | | | | | | | |_| | | | | | | | |____| | |_| | |_) |
 |_|  |_|_|_|_|\___|_| |_|_| |_|_|\__,_|_| |_| |_|  \_____|_|\__,_|_.__/

QUANTISNET
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

