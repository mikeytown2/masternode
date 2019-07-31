#!/bin/bash

# Run this file
# bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/qt/energi-qt-ubuntu.sh)"

DATA_DIR="${HOME}/.energicore"
QT_BIN_NAME='energi-qt'
API_URL='https://api.github.com/repos/energicryptocurrency/energi/releases/latest'
SNAPSHOT_HASH='gsaqiry3h1ho3nh'

TEMP_FOLDER=$( mktemp -d )
sudo mkdir -p "${HOME}/.local/bin"
BIN_URL=$( wget -4qO- -o- "${API_URL}" | jq -r '.assets[].browser_download_url' | grep -v debug | grep -v '.sig' | grep linux )

wget -4qo- "${BIN_URL}" -O "${TEMP_FOLDER}/linux.tar.gz" --show-progress --progress=bar:force 2>&1
tar -xzf "${TEMP_FOLDER}/linux.tar.gz" -C "${TEMP_FOLDER}"
find "${TEMP_FOLDER}" -name "${QT_BIN_NAME}" -size +128k -exec cp {} "${HOME}/.local/bin" \;
rm -rf "${TEMP_FOLDER}"

echo "Downloading the latest snapshot to ${DATA_DIR}"
mkdir -p "${DATA_DIR}"
wget -4qo- "https://www.dropbox.com/s/${SNAPSHOT_HASH}/blocks_n_chains.tar.gz?dl=1" -o "${DATA_DIR}/blocks_n_chains.tar.gz" --show-progress --progress=bar:force 2>&1

echo "Remove blocks and chains databases."
rm -rf "${DATA_DIR}/blocks/"
rm -rf "${DATA_DIR}/chainstate/"
rm -rf "${DATA_DIR}/database/"
rm -f "${DATA_DIR}/.lock"
rm -f "${DATA_DIR}/banlist.dat"
rm -f "${DATA_DIR}/db.log"
rm -f "${DATA_DIR}/debug.log"
rm -f "${DATA_DIR}/fee_estimates.dat"
rm -f "${DATA_DIR}/governance.dat"
rm -f "${DATA_DIR}/mempool.dat"
rm -f "${DATA_DIR}/mncache.dat"
rm -f "${DATA_DIR}/mnpayments.dat"
rm -f "${DATA_DIR}/netfulfilled.dat"
rm -f "${DATA_DIR}/peers.dat"

echo "Extract the snapshot into ${DATA_DIR}/"
tar -xzf "${DATA_DIR}/blocks_n_chains.tar.gz" -C "${DATA_DIR}/"

# Create desktop shortcut.
mkdir -p "${HOME}/Desktop"
printf "[Desktop Entry]
Type=Application
Exec=${HOME}/.local/bin/${QT_BIN_NAME}
" > "${HOME}/Desktop/${QT_BIN_NAME}"
