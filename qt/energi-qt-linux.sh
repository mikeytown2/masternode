#!/bin/bash

# Run this file
# bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/qt/energi-qt-linux.sh)"

# Install jq if not there.
if ! [ -x "$( command -v jq )" ]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq gzip libc-bin
fi
if ! [ -x "$( command -v jq )" ]
then
  sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a
  sudo DEBIAN_FRONTEND=noninteractive add-apt-repository universe
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
  sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -yq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq gzip libc-bin
fi

DATA_DIR="${HOME}/.energicore"
QT_BIN_NAME='energi-qt'
SHORTCUT_NAME='Energi'
API_URL='api.github.com/repos/energicryptocurrency/energi/releases/latest'
SNAPSHOT_HASH='gsaqiry3h1ho3nh'
ICON_URL='assets.coingecko.com/coins/images/5795/large/energi.png'
ICON_NAME='energi.png'

echo "Creating folders"
USRNAME_CURRENT=$( whoami )
#sudo chown -R "${USRNAME_CURRENT}:${USRNAME_CURRENT}" "${HOME}"
sudo mkdir -p "${HOME}/.local/bin/"
sudo chown -R "${USRNAME_CURRENT}:${USRNAME_CURRENT}" "${HOME}/.local/bin/"
sudo mkdir -p "${HOME}/.local/share/applications/"
sudo chown -R "${USRNAME_CURRENT}:${USRNAME_CURRENT}" "${HOME}/.local/share/applications/"
sudo mkdir -p "${HOME}/Desktop/"
sudo chown -R "${USRNAME_CURRENT}:${USRNAME_CURRENT}" "${HOME}/Desktop/"
sudo mkdir -p "${HOME}/Pictures/"
sudo chown -R "${USRNAME_CURRENT}:${USRNAME_CURRENT}" "${HOME}/Pictures/"
sudo mkdir -p "${DATA_DIR}/"
sudo chown -R "${USRNAME_CURRENT}:${USRNAME_CURRENT}" "${DATA_DIR}/"
TEMP_FOLDER=$( mktemp -d )

echo "Downloading ${API_URL}"
GITHUB_LATEST=$( wget --no-check-certificate -4qO- -o- "${API_URL}" )
BIN_URL=$( echo "${GITHUB_LATEST}" | jq -r '.assets[].browser_download_url' | grep -v debug | grep -v '.sig' | grep linux )
VERSION=$( echo "${GITHUB_LATEST}" | jq -r '.tag_name' )

echo "Downloading ${BIN_URL}"
wget -4qo- "${BIN_URL}" -O "${TEMP_FOLDER}/linux.tar.gz" --show-progress --progress=bar:force 2>&1
tar -xzf "${TEMP_FOLDER}/linux.tar.gz" -C "${TEMP_FOLDER}" --warning=no-timestamp
find "${TEMP_FOLDER}" -name "${QT_BIN_NAME}" -size +128k -exec cp {} "${HOME}/.local/bin" \;
rm -rf "${TEMP_FOLDER}"
sudo chmod +x "${HOME}/.local/bin/${QT_BIN_NAME}"
echo "Checking ${HOME}/.local/bin/${QT_BIN_NAME}"
ldd "${HOME}/.local/bin/${QT_BIN_NAME}"
uname -a

if [[ ! -d ${DATA_DIR}/blocks ]]
then
  if [[ ! -f "${DATA_DIR}/blocks_n_chains.tar.gz" ]]
  then
    echo "Downloading the latest snapshot to ${DATA_DIR}"
    wget -4qo- "www.dropbox.com/s/${SNAPSHOT_HASH}/blocks_n_chains.tar.gz?dl=1" -O "${DATA_DIR}/blocks_n_chains.tar.gz" --show-progress --progress=bar:force 2>&1
  fi

  echo "Extract the snapshot into ${DATA_DIR}/ (give it a minute to complete)"
  tar -xzf "${DATA_DIR}/blocks_n_chains.tar.gz" -C "${DATA_DIR}/" --warning=no-timestamp
fi

wget -4qo- "${ICON_URL}" -O "${HOME}/Pictures/${ICON_NAME}"  --show-progress --progress=bar:force 2>&1

# Create desktop shortcut.
echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Version=${VERSION}
Type=Application
Terminal=false
Name=${SHORTCUT_NAME}
Comment=${SHORTCUT_NAME}
Exec=${HOME}/.local/bin/${QT_BIN_NAME}
Icon=${HOME}/Pictures/${ICON_NAME}
" > "${HOME}/Desktop/${QT_BIN_NAME}.desktop"
sudo chmod +x "${HOME}/Desktop/${QT_BIN_NAME}.desktop"

# Create launcher shortcut.
echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Version=${VERSION}
Type=Application
Terminal=false
Categories=Finance;Office
Name=${SHORTCUT_NAME}
Comment=${SHORTCUT_NAME}
Exec=${HOME}/.local/bin/${QT_BIN_NAME}
Icon=${HOME}/Pictures/${ICON_NAME}
" > "${HOME}/.local/share/applications/${QT_BIN_NAME}.desktop"
sudo chmod +x "${HOME}/.local/share/applications/${QT_BIN_NAME}.desktop"
