#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/nocollateral/dinerod.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='dinerocoin/dinero'
# Display Name.
DAEMON_NAME='Dinero Core'
# Coin Ticker.
TICKER='DIN'
# Binary base name.
BIN_BASE='dinero'
# Directory.
DIRECTORY='.dinerocore'
# Conf File.
CONF='dinero.conf'
# Port.
DEFAULT_PORT=26285
# Explorer URL.
EXPLORER_URL='https://din.overemo.com/'
# Rate limit explorer.
EXPLORER_SLEEP=1
# Amount of Collateral needed.
COLLATERAL=5000
# Cycle Daemon on first start.
DAEMON_CYCLE=1
# Multiple on single IP.
MULTI_IP_MODE=3

SENTINEL_GITHUB='https://github.com/dinerocoin/sentinel.git'
SENTINEL_CONF_START="dinero_conf"

# Tip Address.
TIPS='DHmJEK4Pn1UiJHULKmqVk9rw6r2ALUnNim'
# Dropbox Addnodes
DROPBOX_ADDNODES='gj6ff243ld2g974'
# If set to 1 then use addnodes from dropbox.
USE_DROPBOX_ADDNODES=1
# Dropbox Bootstrap
DROPBOX_BOOTSTRAP='6exy1p7qc47002y'
# If set to 1 then use bootstrap from dropbox.
USE_DROPBOX_BOOTSTRAP=1
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='y9x7p9ae6b0zr35'

ASCII_ART () {
echo -e "\e[0m"
clear 2> /dev/null
cat << "DINERO"
 ____  _                         ____
|  _ \(_)_ __   ___ _ __ ___    / ___|___  _ __ ___
| | | | | '_ \ / _ \ '__/ _ \  | |   / _ \| '__/ _ \
| |_| | | | | |  __/ | | (_) | | |__| (_) | | |  __/
|____/|_|_| |_|\___|_|  \___/   \____\___/|_|  \___|

DINERO
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

