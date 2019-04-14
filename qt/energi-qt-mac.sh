#!/bin/bash

# Run this file
# bash -i <( curl -sL https://raw.githack.com/mikeytown2/masternode/master/qt/energi-qt-mac.sh )

DATA_DIR='EnergiCore'
QT_BIN_NAME='Energi-Qt'
SNAPSHOT_HASH='gsaqiry3h1ho3nh'

echo "Stopping ${QT_BIN_NAME} if it's running."
sudo killall -I -q "${QT_BIN_NAME}"

echo "Downloading the latest snapshot to ${HOME}/Library/Application Support/${DATA_DIR}/"
curl -L "https://www.dropbox.com/s/${SNAPSHOT_HASH}/blocks_n_chains.tar.gz?dl=1" -o "${HOME}/Library/Application Support/${DATA_DIR}/blocks_n_chains.tar.gz"

echo "Remove blocks and chains databases."
rm -rf "${HOME}/Library/Application Support/${DATA_DIR}/blocks/"
rm -rf "${HOME}/Library/Application Support/${DATA_DIR}/chainstate/"
rm -rf "${HOME}/Library/Application Support/${DATA_DIR}/database/"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/.lock"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/banlist.dat"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/db.log"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/debug.log"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/fee_estimates.dat"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/governance.dat"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/mempool.dat"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/mncache.dat"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/mnpayments.dat"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/netfulfilled.dat"
rm -f "${HOME}/Library/Application Support/${DATA_DIR}/peers.dat"

echo "Extract the snapshot into ${HOME}/Library/Application Support/${DATA_DIR}/"
tar -xzf "${HOME}/Library/Application Support/${DATA_DIR}/blocks_n_chains.tar.gz" -C "${HOME}/Library/Application Support/${DATA_DIR}/"

echo "Starting the ${QT_BIN_NAME} wallet"
"/Applications/${QT_BIN_NAME}.app/Contents/MacOS/${QT_BIN_NAME}"
