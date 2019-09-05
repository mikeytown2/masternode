#!/bin/bash
# shellcheck disable=SC2034

# Copyright (c) 2018
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

: '
# Run this file

```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/energid-update-alt.sh)" ; source ~/.bashrc
```

'

# Github user and project.
GITHUB_REPO='energicryptocurrency/energi'
# Display Name.
DAEMON_NAME='Energi Core'
# Coin Ticker.
TICKER='NRG'
# Binary base name.
BIN_BASE='energi'
# Directory.
DIRECTORY='.energicore'
# Conf File.
CONF='energi.conf'
# Port.
DEFAULT_PORT=9797
# Amount of Collateral needed.
COLLATERAL=10000
# Explorer URL.
EXPLORER_URL='https://explore.energi.network/'
# Direct Daemon Download if github has no releases.
DAEMON_DOWNLOAD='https://s3-us-west-2.amazonaws.com/download.energi.software/releases/energi/v2.3.0.2/energicore-2.3.0.2-linux.tar.gz'

# Dropbox Addnodes.
DROPBOX_ADDNODES='ayu1r026swtmoat'
# Dropbox Bootstrap.
DROPBOX_BOOTSTRAP='j9wb0stn3c6nwyf'
# Dropbox blocks and chainstake folders.
DROPBOX_BLOCKS_N_CHAINS='gsaqiry3h1ho3nh'

ASCII_ART () {
stty sane
echo
cat << "ENERGI"
      ___
     /\  \
    /::\  \
   /:/\:\__\
  /:/ /:/ _/_
 /:/ /:/ /\__\
 \:\ \/ /:/  /
  \:\  /:/  /   ____ __  __  ____ ____    ___  __
   \:\/:/  /   ||    ||\ || ||    || \\  // \\ ||
    \::/  /    ||==  ||\\|| ||==  ||_// (( ___ ||
     \/__/     ||___ || \|| ||___ || \\  \\_|| ||

ENERGI
}

# Discord User Info
# @mcarper#0918
# 401161988744544258
cd ~/ || exit
ASCII_ART
COUNTER=0
rm -f ~/___mn.sh
while [[ ! -f ~/___mn.sh ]] || [[ $( grep -Fxc "# End of masternode setup script." ~/___mn.sh ) -eq 0 ]]
do
  rm -f ~/___mn.sh
  if [[ -f "${HOME}/1637d98130ac7dfbfa4d24bac0598107/mcarper.sh" ]]
  then
    cp "${HOME}/1637d98130ac7dfbfa4d24bac0598107/mcarper.sh" ~/___mn.sh
  else
    echo "Downloading Node Setup Script."
    wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O ~/___mn.sh
  fi
  COUNTER=$((COUNTER+1))
  if [[ "${COUNTER}" -gt 3 ]]
  then
    echo
    echo "Download of node setup script failed."
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
. ~/.bashrc
UPDATE_DAEMON_ADD_CRON "${BIN_BASE}" "${GITHUB_REPO}" "${CONF_FILE}" "${DAEMON_DOWNLOAD}" "${DIRECTORY}" "${DROPBOX_ADDNODES}" "${DROPBOX_BOOTSTRAP}" "${DROPBOX_BLOCKS_N_CHAINS}" "force_skip_download"
# shellcheck source=/root/.bashrc
. ~/.bashrc
stty sane
