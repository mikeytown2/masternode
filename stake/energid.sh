#!/bin/bash

# Copyright (c) 2019
# All rights reserved.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# shellcheck disable=SC2016
: '
# Run this file
```
bash -ic "$(wget -4qO- -o- raw.githubusercontent.com/mikeytown2/masternode/master/stake/energid.sh)" ; source ~/.bashrc
```
'

echo
echo "This file will setup or transform an already running node into a hot staking"
echo "wallet that'll run 24/7. You'll need to transfer your wallet.dat or dumpwallet"
echo "output in order to do so."
REPLY=''
read -p "Proceed with the script (y/n)?: " -r
echo
REPLY=${REPLY,,} # tolower
if [[ "${REPLY}" == 'n' ]]
then
  return 1 2>/dev/null || exit 1
fi

TEMP_FILENAME1=$( mktemp )
SP="/-\\|"

if [ ! -x "$( command -v aria2c )" ] || [ ! -x "$( command -v unattended-upgrade )" ] || [ ! -x "$( command -v ntpdate )" ] || [ ! -x "$( command -v google-authenticator )" ] || [ ! -x "$( command -v php )" ] || [ ! -x "$( command -v jq )" ]  || [ ! -x "$( command -v qrencode )" ]
then
  echo "Updating linux first."
  sleep 1
  echo "Running apt-get update."
  sleep 2
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq
  echo "Running apt-get upgrade."
  sleep 2
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
  echo "Running apt-get dist-upgrade."
  sleep 2
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

  if [ ! -x "$( command -v unattended-upgrade )" ]
  then
    echo "Running apt-get install unattended-upgrades php ufw."
    sleep 1
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq unattended-upgrades php ufw
    if [ ! -f /etc/apt/apt.conf.d/20auto-upgrades ]
    then
      # Enable auto updating of Ubuntu security packages.
      cat << UBUNTU_SECURITY_PACKAGES | sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
APT::Periodic::Enable "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
UBUNTU_SECURITY_PACKAGES
    fi
  fi
fi

# Have linux passwords show stars.
if [[ -f /etc/sudoers ]] && [[ $( sudo grep -c 'env_reset,pwfeedback' /etc/sudoers ) -eq 0 ]]
then
  echo "Show password feeback."
  sudo cat /etc/sudoers | sed -r 's/^Defaults(\s+)env_reset$/Defaults\1env_reset,pwfeedback/' | sudo EDITOR='tee ' visudo >/dev/null
  echo "Restarting ssh."
  sudo systemctl restart sshd
fi

_restrict_logins() {
  USRS_THAT_CAN_LOGIN=$( whoami )
  USRS_THAT_CAN_LOGIN="root ubuntu ${USRS_THAT_CAN_LOGIN}"
  USRS_THAT_CAN_LOGIN=$( echo "${USRS_THAT_CAN_LOGIN}" | xargs -n1 | sort -u | xargs )
  ALL_USERS=$( cut -d: -f1 /etc/passwd )

  BOTH_LISTS=$( sort <( echo "${USRS_THAT_CAN_LOGIN}" | tr " " '\n' ) <( echo "${ALL_USERS}" | tr " " '\n' ) | uniq -d | grep -Ev "^$" )
  if [[ $( grep -cE '^AllowUsers' /etc/ssh/sshd_config ) -gt 0 ]]
  then
    USRS_THAT_CAN_LOGIN_2=$( grep -E '^AllowUsers' /etc/ssh/sshd_config | sed -e 's/^AllowUsers //g' )
    BOTH_LISTS=$( echo "${USRS_THAT_CAN_LOGIN_2} ${BOTH_LISTS}" | xargs -n1 | sort -u | xargs )
    MISSING_FROM_LISTS=$( join -v 2 <(sort <( echo "${USRS_THAT_CAN_LOGIN_2}" | tr " " '\n' ))  <(sort <( echo "${BOTH_LISTS}" | tr " " '\n' ) ))
  else
    MISSING_FROM_LISTS="${BOTH_LISTS}"
  fi
  if [[ -z "${BOTH_LISTS}" ]]
  then
    echo "User login can not be restricted."
    return
  fi
  if [[ -z "${MISSING_FROM_LISTS}" ]]
  then
    # Do nothing if no users are missing.
    return
  fi
  echo
  echo "${BOTH_LISTS}"
  REPLY=''
  read -p "Make it so only the above list of users can login via SSH (y/n)?: " -r
  REPLY=${REPLY,,} # tolower
  if [[ "${REPLY}" == 'y' ]] || [[ -z "${REPLY}" ]]
  then
    if [[ $( grep -cE '^AllowUsers' /etc/ssh/sshd_config ) -eq 0 ]]
    then
      echo "AllowUsers ${BOTH_LISTS}" >> /etc/ssh/sshd_config
    else
      sudo sed -ie "/AllowUsers/ s/$/ ${MISSING_FROM_LISTS} /" /etc/ssh/sshd_config
    fi
    USRS_THAT_CAN_LOGIN=$( grep -E '^AllowUsers' /etc/ssh/sshd_config | sed -e 's/^AllowUsers //g' | tr " " '\n' )
    echo "Restarting ssh."
    sudo systemctl restart sshd
    echo "List of users that can login via SSH (/etc/ssh/sshd_config):"
    echo "${USRS_THAT_CAN_LOGIN}"
  fi
}

_setup_two_factor() {
  sudo service apache2 stop 2>/dev/null
  sudo update-rc.d apache2 disable 2>/dev/null
  sudo update-rc.d apache2 remove 2>/dev/null

  # Ask to review if .google_authenticator file already exists.
  if [[ -s "${HOME}/.google_authenticator" ]]
  then
    REPLY=''
    read -p "Review 2 factor authentication code for password SSH login (y/n)?: " -r
    REPLY=${REPLY,,} # tolower
    if [[ "${REPLY}" == 'n' ]] || [[ -z "${REPLY}" ]]
    then
      return
    fi
  fi

  # Clear out an old failed run.
  if [[ -f "${HOME}/.google_authenticator.temp" ]]
  then
    rm "${HOME}/.google_authenticator.temp"
  fi

  # Install google-authenticator if not there.
  NEW_PACKAGES=''
  if [ ! -x "$( command -v google-authenticator )" ]
  then
    NEW_PACKAGES="${NEW_PACKAGES} libpam-google-authenticator"
  fi
  if [ ! -x "$( command -v php )" ]
  then
    NEW_PACKAGES="${NEW_PACKAGES} php-cli"
  fi
  if [ ! -x "$( command -v qrencode )" ]
  then
    NEW_PACKAGES="${NEW_PACKAGES} qrencode"
  fi
  if [[ ! -z "${NEW_PACKAGES}" ]]
  then
    # shellcheck disable=SC2086
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ${NEW_PACKAGES}

    sudo service apache2 stop 2>/dev/null
    sudo update-rc.d apache2 disable 2>/dev/null
    sudo update-rc.d apache2 remove 2>/dev/null
  fi

  if [[ -f "${HOME}/masternode/stake/otp.php" ]]
  then
    cp "${HOME}/masternode/stake/otp.php" /tmp/___otp.php
  else
    wget -4qo- https://raw.githack.com/mikeytown2/masternode/master/stake/otp.php -O /tmp/___otp.php
  fi

  # Generate otp.
  IP_ADDRESS=$( timeout --signal=SIGKILL 10s wget -4qO- -T 10 -t 2 -o- http://ipinfo.io/ip )
  USRNAME=$( whoami )
  SECRET=''
  if [[ -f "${HOME}/.google_authenticator" ]]
  then
    SECRET=$( sudo head -n 1 "${HOME}/.google_authenticator" 2>/dev/null )
  fi
  if [[ -z "${SECRET}" ]]
  then
    sudo google-authenticator -t -d -f -r 10 -R 30 -w 5 -q -Q UTF8 -l "ssh login for '${USRNAME}'"
    # Add 5 recovery digits.
    {
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    } | sudo tee -a  "${HOME}/.google_authenticator" >/dev/null
    SECRET=$( sudo head -n 1 "${HOME}/.google_authenticator" 2>/dev/null )
  fi
  if [[ -z "${SECRET}" ]]
  then
    echo "Google Authenticator install failed."
    return
  fi

  mv "${HOME}/.google_authenticator" "${HOME}/.google_authenticator.temp"

  stty sane 2>/dev/null
  echo "Warning: pasting the following URL into your browser exposes the OTP secret to Google:"
  echo "https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/ssh%2520login%2520for%2520'${USRNAME}'%3Fsecret%3D${SECRET}%26issuer%3D${IP_ADDRESS}"
  echo
  stty sane 2>/dev/null
  qrencode -l L -m 2 -t UTF8 "otpauth://totp/ssh%20login%20for%20'${USRNAME}'?secret=${SECRET}&issuer=${IP_ADDRESS}"
  stty sane 2>/dev/null
  echo "Scan the QR code with the Google Authenticator app; or manually enter"
  echo "Account: ${USRNAME}@${IP_ADDRESS}"
  echo "Key: ${SECRET}"
  echo "This is a time based code"
  echo "When logging into this VPS via password, a 6 digit code would also be required."
  echo "If you loose this code you can still use your wallet on your desktop."
  echo

  # Validate otp.
  while :
  do
    REPLY=''
    read -p "6 digit verification code (leave blank to disable & delete): " -r
    if [[ -z "${REPLY}" ]]
    then
      rm -f "${HOME}/.google_authenticator"
      rm -f "${HOME}/.google_authenticator.temp"
      echo "Not going to use google authenticator."
      return
    fi

    KEY_CHECK=$( php /tmp/___otp.php "${REPLY}" "${HOME}/.google_authenticator.temp" )
    if [[ ! -z "${KEY_CHECK}" ]]
    then
      echo "${KEY_CHECK}"
      if [[ $( echo "${KEY_CHECK}" | grep -ic 'Key Verified' ) -gt 0 ]]
      then
        break
      fi
    fi
  done

  if [[ -f "${HOME}/.google_authenticator.temp" ]]
  then
    mv "${HOME}/.google_authenticator.temp" "${HOME}/.google_authenticator"
  fi

  echo "Your emergency scratch codes are (write these down in a safe place):"
  grep -oE "[0-9]{8}" "${HOME}/.google_authenticator" | awk '{print "  " $1 }'

  read -r -p $'Use this 2 factor code \e[7m(y/n)\e[0m? ' -e 2>&1
  REPLY=${REPLY,,} # tolower
  if [[ "${REPLY}" == 'y' ]]
  then
    if [[ $( grep -c 'auth required pam_google_authenticator.so nullok' /etc/pam.d/sshd ) -eq 0 ]]
    then
      echo "auth required pam_google_authenticator.so nullok" | sudo tee -a "/etc/pam.d/sshd" >/dev/null
    fi
    sudo sed -ie 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
    sudo systemctl restart sshd.service
    echo
    echo "If using Bitvise select keyboard-interactive with no submethods selected."
    echo

    # Allow for 20 bad root login attempts before killing the ip.
    if [[ -f /etc/denyhosts.conf ]]
    then
      sudo sed -ie 's/DENY_THRESHOLD_ROOT \= 1/DENY_THRESHOLD_ROOT = 5/g' /etc/denyhosts.conf
      sudo sed -ie 's/DENY_THRESHOLD_RESTRICTED \= 1/DENY_THRESHOLD_RESTRICTED = 5/g' /etc/denyhosts.conf
      sudo sed -ie 's/DENY_THRESHOLD_ROOT \= 1/DENY_THRESHOLD_ROOT = 20/g' /etc/denyhosts.conf
      sudo sed -ie 's/DENY_THRESHOLD_RESTRICTED \= 1/DENY_THRESHOLD_RESTRICTED = 20/g' /etc/denyhosts.conf
      sudo systemctl restart denyhosts
    fi
    sleep 5
    clear
  else
    rm -f "${HOME}/.google_authenticator"
  fi
}

_add_rsa_key() {
  while :
  do
    TEMP_FILE_NAME1=$( mktemp )
    printf "Enter the PUBLIC ssh key (starts with ssh-rsa AAAA) and press [ENTER]:\n\n"
    read -r SSH_RSA_PUBKEY
    if [[ "${#SSH_RSA_PUBKEY}" -lt 10 ]]
    then
      echo "Quiting without adding rsa key."
      echo
      break
    fi
    echo "${SSH_RSA_PUBKEY}" >> "${TEMP_FILE_NAME1}"
    SSH_TEST=$( ssh-keygen -l -f "${TEMP_FILE_NAME1}"  2>/dev/null )
    if [[ "${#SSH_TEST}" -gt 10 ]]
    then
      touch "${HOME}/.ssh/authorized_keys"
      chmod 644 "${HOME}/.ssh/authorized_keys"
      echo "${SSH_RSA_PUBKEY}" >> "${HOME}/.ssh/authorized_keys"
      echo "Added ${SSH_TEST}"
      echo
      break
    fi

    rm "${TEMP_FILE_NAME1}"
  done
}

_check_clock() {
  if [ ! -x "$( command -v ntpdate )" ]
  then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ntpdate
  fi
  echo "Checking system clock..."
  ntpdate -q pool.ntp.org | tail -n 1 | grep -o 'offset.*' | awk '{print $1 ": " $2 " " $3 }'
}

_get_node_info() {
  USRNAME="${1}"
  CONF_FILE="${2}"
  DAEMON_BIN="${3}"
  CONTROLLER_BIN="${4}"

  # Install ffsend and jq as well.
  if [ ! -x "$( command -v snap )" ] || [ ! -x "$( command -v jq )" ] || [ ! -x "$( command -v column )" ]
  then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq snap
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq snapd
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq bsdmainutils
  fi
  if [ ! -x "$( command -v ffsend )" ]
  then
    sudo snap install ffsend
  fi

  if [ ! -x "$( command -v ffsend )" ]
  then
    FFSEND_URL=$( wget -4qO- -o- https://api.github.com/repos/timvisee/ffsend/releases/latest | jq -r '.assets[].browser_download_url' | grep static | grep linux )
    mkdir -p "${HOME}/.local/bin/"
    wget -4q -o- "${FFSEND_URL}" -O "${HOME}/.local/bin/ffsend"
    chmod +x "${HOME}/.local/bin/ffsend"
  fi

  # Load in functions.
  stty sane 2>/dev/null
  if [ -z "${PS1}" ]
  then
    PS1="\\"
  fi
  cd "${HOME}" || return 1 2>/dev/null
  # shellcheck disable=SC1090
  source "${HOME}/.bashrc"
  if [ "${PS1}" == "\\" ]
  then
    PS1=''
  fi
  stty sane 2>/dev/null

  AUTH_LIST=$( wget -4qO- -o- https://api.github.com/repos/mikeytown2/masternode/contents/ | jq -r '.[].name' | grep 'd.sh' )

  # Get info via username alias.
  if [[ ! -z "${USRNAME}" ]] && [[ "$( type "${USRNAME}" 2>/dev/null | grep -c '_masternode_dameon_2' )" -eq 1 ]]
  then
    if [[ -z "${DAEMON_BIN}" ]]
    then
      DAEMON_BIN=$( "${USRNAME}" daemon )
      if [[ $( echo "${AUTH_LIST}" | grep -c "${DAEMON_BIN}" ) -eq 0 ]]
      then
        return
      fi
    fi
    if [[ -z "${CONTROLLER_BIN}" ]]
    then
      CONTROLLER_BIN=$( "${USRNAME}" daemon )
    fi
    if [[ -z "${CONF_FILE}" ]]
    then
      CONF_FILE=$( "${USRNAME}" conf loc )
    fi
  fi

  # Get info the hard way.
  if [[ -z "${CONF_FILE}" ]] || [[ -z "${DAEMON_BIN}" ]] || [[ -z "${CONTROLLER_BIN}" ]]
  then
    LSLOCKS_OUTPUT=$( sudo lslocks -o COMMAND,PID,PATH | grep -oE ".*/blocks" | sed 's/blocks$//g' )
    if [[ -z "${LSLOCKS_OUTPUT}" ]]
    then
      if [[ ! -z "${DAEMON_BIN}" ]]
      then
        REPLY='y'
        read -p "Install a new ${DAEMON_BIN} node on this vps (y/n)?: " -r
        REPLY=${REPLY,,} # tolower
        if [[ "${REPLY}" == 'y' ]]
        then
          bash -ic "$(wget -4qO- -o- "raw.githubusercontent.com/mikeytown2/masternode/master/${DAEMON_BIN}.sh")" -- NO_MN
          # shellcheck disable=SC1090
          source "${HOME}/.bashrc"
          _get_node_info "${USRNAME}" "${CONF_FILE}" "${DAEMON_BIN}" "${CONTROLLER_BIN}"
        fi
      fi
      return
    fi

    RUNNING_NODES=$( echo "${LSLOCKS_OUTPUT}" | awk '{print $1 " " $3 }' )
    # Filter if daemon bin given.
    if [[ ! -z "${DAEMON_BIN}" ]]
    then
      RUNNING_NODES=$( echo "${RUNNING_NODES}" | grep "^${DAEMON_BIN} " )
    fi
    # Filter if conf file given.
    if [[ ! -z "${CONF_FILE}" ]]
    then
      CONF_DIR=$( dirname "${CONF_FILE}" )
      RUNNING_NODES=$( echo "${RUNNING_NODES}" | grep "${CONF_DIR}" )
    fi
    # Filter if username given.
    if [[ ! -z "${USRNAME}" ]] && [[ $( echo "${RUNNING_NODES}" | grep -c "${USRNAME}" ) -gt 0 ]]
    then
      RUNNING_NODES=$( echo "${RUNNING_NODES}" | grep "${USRNAME}" )
    fi
    if [[ -z "${RUNNING_NODES}" ]]
    then
      return
    fi

    RUNNING_NODES=$( echo "${RUNNING_NODES}" | sort | cat -n | column -t )
    if [[ "$( echo "${RUNNING_NODES}" | wc -l )" -gt 1 ]]
    then
      echo
      echo "Leave blank to exit."
      echo "Select the number of the node you wish to copy your wallet to:"
      echo "${RUNNING_NODES}"
      REPLY=''
      while [[ -z "${REPLY}" ]] || [[ "$( echo "${RUNNING_NODES}" | grep -cE "^${REPLY} " )" -eq 0 ]]
      do
        read -p "Number: " -r
        if [[ -z "${REPLY}" ]]
        then
          return
        fi
      done
    else
      REPLY=1
    fi
    CONF_DIR=$( echo "${RUNNING_NODES}" | grep -E "^${REPLY} " | awk '{print $3}' )
    CONF_FILE=$( grep -rl -m 1 --include \*.conf 'rpcuser\=' "${CONF_DIR}" )

    if [[ -z "${DAEMON_BIN}" ]]
    then
      DAEMON_BIN=$( echo "${RUNNING_NODES}" | grep -E "^${REPLY} " | awk '{print $2}' )
    fi
    if [[ $( echo "${AUTH_LIST}" | grep -c "${DAEMON_BIN}" ) -eq 0 ]]
    then
      return
    fi

    NODE_PID=$( echo "${LSLOCKS_OUTPUT}" | grep "${CONF_DIR}" | awk '{print $2}' )
    if [[ -z "${USRNAME}" ]]
    then
      USRNAME=$( ps -u -p "${NODE_PID}" | tail -n 1 | awk '{print $1}' )
    fi

    if [[ -z "${CONTROLLER_BIN}" ]]
    then
      PID_PATH=$( sudo readlink -f "/proc/${NODE_PID}/exe" )
      if [[ "${#PID_PATH}" -lt 4 ]]
      then
        return
      fi
      if [[ -f "${PID_PATH::-1}-cli" ]]
      then
        CONTROLLER_BIN=$( basename "${PID_PATH::-1}-cli" )
      else
        CONTROLLER_BIN="${DAEMON_BIN}"
      fi
    fi
  fi

  if [[ $( echo "${AUTH_LIST}" | grep -c "${DAEMON_BIN}" ) -eq 0 ]]
  then
    return
  fi

  echo "${USRNAME} ${CONF_FILE} ${DAEMON_BIN} ${CONTROLLER_BIN}" > "${TEMP_FILENAME1}"
  return
}

_copy_wallet() {
  _get_node_info "${1}" "${2}" "${3}" "${4}"
  read -r USRNAME CONF_FILE DAEMON_BIN CONTROLLER_BIN < "${TEMP_FILENAME1}"
  if [[ -z "${CONF_FILE}" ]]
  then
    return
  fi
  CONF_DIR=$( dirname "${CONF_FILE}" )

  # Update mn script.
  cd "${HOME}" || exit
  COUNTER=0
  rm -f "${HOME}/___mn.sh"
  while [[ ! -f "${HOME}/___mn.sh" ]] || [[ $( grep -Fxc "# End of masternode setup script." "${HOME}/___mn.sh" ) -eq 0 ]]
  do
    rm -f "${HOME}/___mn.sh"
    echo "Downloading Setup Script."
    wget -4qo- gist.githack.com/mikeytown2/1637d98130ac7dfbfa4d24bac0598107/raw/mcarper.sh -O "${HOME}/___mn.sh"
    COUNTER=$(( COUNTER + 1 ))
    if [[ "${COUNTER}" -gt 3 ]]
    then
      echo
      echo "Download of setup script failed."
      echo
      exit 1
    fi
  done
  echo "${DAEMON_BIN}"
  if [[ -z "${DAEMON_BIN}" ]]
  then
    echo "Setup encountered an error; please ask for help."
    return
  fi
  sed -i "1iDAEMON_BIN='${DAEMON_BIN}'" "${HOME}/___mn.sh"
  bash "${HOME}/___mn.sh" UPDATE_BASHRC

  # Load in functions.
  stty sane 2>/dev/null
  if [ -z "${PS1}" ]
  then
    PS1="\\"
  fi
  cd "${HOME}" || return 1 2>/dev/null
  # shellcheck disable=SC1090
  source "${HOME}/.bashrc"
  if [ "${PS1}" == "\\" ]
  then
    PS1=''
  fi
  stty sane 2>/dev/null
  rm "${HOME}/___mn.sh"

  # Wait for wallet to load; start if needed.
  _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded

  # Wait for mnsync
  MNSYNC_WAIT_FOR='999'
  echo "Waiting for mnsync status..."
  echo "This can sometimes take up 10 minutes; please wait for mnsync."
  i=0
  while [[ $( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' mnsync status | grep -cF "${MNSYNC_WAIT_FOR}" ) -eq 0 ]]
  do
    PERCENT_DONE=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' daemon_log tail 2000 | grep -m 1 -o 'nSyncProgress.*\|Progress.*' | tr '=' ' ' | awk -v SF=100 '{printf($2*SF )}' )
    echo -e "\\r${SP:i++%${#SP}:1} Percent Done: %${PERCENT_DONE}      \\c"
    sleep 0.3
  done

  echo
  echo
  WALLET_BALANCE=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' getbalance )
  echo "Current wallet.dat balance on this VPS: ${WALLET_BALANCE}"
  if [[ "${WALLET_BALANCE}" != 0 ]]
  then
    REPLY=''
    read -p "Do you want to replace this wallet.dat file (y/n)?: " -r
    REPLY=${REPLY,,} # tolower
    if [[ -z "${REPLY}" ]] || [[ "${REPLY}" == 'n' ]]
    then
      return
    fi
  fi

  echo
  echo "This script uses https://send.firefox.com/ to transfer files from your"
  echo "desktop computer onto the vps. You can read more about the service here"
  echo "https://en.wikipedia.org/wiki/Firefox_Send"
  sleep 5
  echo
  echo "Target: ${CONF_DIR}"
  echo "Please encrypted your wallet.dat file if it is not encrypted."
  sleep 2
  echo "Shutdown your desktop wallet and upload wallet.dat to"
  echo "https://send.firefox.com/"
  sleep 2
  echo "Start your desktop wallet."
  echo "Paste in the url to your wallet.dat file below."
  sleep 2
  echo
  REPLY=''
  while [[ -z "${REPLY}" ]] || [[ "$( echo "${REPLY}" | grep -c 'https://send.firefox.com/download/' )" -eq 0 ]]
  do
    read -p "URL (leave blank do it manually (sftp/scp)): " -r
    if [[ -z "${REPLY}" ]]
    then
      MD5_WALLET_BEFORE=$( sudo md5sum "${CONF_DIR}/wallet.dat" )
      MD5_WALLET_AFTER="${MD5_WALLET_BEFORE}"
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' disable
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' conf edit staking 1
      while [[ "${MD5_WALLET_BEFORE}" == "${MD5_WALLET_AFTER}" ]]
      do
        echo "Please Copy the wallet.dat file to ${CONF_DIR}/wallet.dat on your own"
        read -p "Press Enter Once Done: " -r
        sudo chown "${USRNAME}":"${USRNAME}" "${CONF_DIR}/wallet.dat"
        sudo chmod 600 "${CONF_DIR}/wallet.dat"
        MD5_WALLET_AFTER=$( sudo md5sum "${CONF_DIR}/wallet.dat" )
        if [[ "${MD5_WALLET_BEFORE}" == "${MD5_WALLET_AFTER}" ]]
        then
          REPLY=''
          read -p "wallet.dat hasn't changed; try again (y/n)?: " -r
          REPLY=${REPLY,,} # tolower
          if [[ "${REPLY}" != 'y' ]]
          then
            break
          fi
        fi
      done
      sudo chown "${USRNAME}":"${USRNAME}" "${CONF_DIR}/wallet.dat"
      sudo chmod 600 "${CONF_DIR}/wallet.dat"
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' enable
      # Wait for wallet to load; start if needed.
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded

      # See if wallet.dat can be opened.
      if [[ $( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' daemon_log tail 500 | grep -c "can't open database wallet.dat" ) -gt 0 ]]
      then
        sudo rm "${CONF_DIR}/wallet.dat"
        echo "Wallet was corrupted; try again. Wallet db version could also be different."
        REPLY=''
      else
        return
      fi
    fi
  done

  DATADIR=$( dirname "${CONF_FILE}" )
  DATADIR_FILENAME=$( echo "${DATADIR}" | tr '/' '_' )


  while :
  do
    TEMP_DIR_NAME1=$( mktemp -d -p "${HOME}" )
    if [[ -z "${REPLY}" ]]
    then
      read -p "URL (leave blank to skip): " -r
      if [[ -z "${REPLY}" ]]
      then
        break
      fi
    fi

    # Trim white space.
    REPLY=$( echo "${REPLY}" | xargs )
    if [[ -f "${HOME}/.local/bin/ffsend" ]]
    then
      "${HOME}/.local/bin/ffsend" download -y --verbose "${REPLY}" -o "${TEMP_DIR_NAME1}/"
    else
      ffsend download -y --verbose "${REPLY}" -o "${TEMP_DIR_NAME1}/"
    fi
    fullfile=$( find "${TEMP_DIR_NAME1}/" -type f )
    if [[ -z "${fullfile}" ]]
    then
      echo "Download failed; try again."
      REPLY=''
      continue
    fi
    if [[ $( echo "${fullfile}" | grep -ic 'wallet.dat' ) -gt 0 ]]
    then
      echo "Moving wallet.dat file"
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' disable
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' conf edit staking 1
      sudo mv "${CONF_DIR}/wallet.dat" "${CONF_DIR}/wallet.dat.bak"
      sudo mv "${fullfile}" "${CONF_DIR}/wallet.dat"
      sudo chown "${USRNAME}":"${USRNAME}" "${CONF_DIR}/wallet.dat"
      sudo chmod 600 "${CONF_DIR}/wallet.dat"
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' enable
      # Wait for wallet to load; start if needed.
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded

      # See if wallet.dat can be opened.
      if [[ $( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' daemon_log tail 500 | grep -c "can't open database wallet.dat" ) -gt 0 ]]
      then
        sudo rm "${CONF_DIR}/wallet.dat"
        sudo mv "${CONF_DIR}/wallet.dat.bak" "${CONF_DIR}/wallet.dat"
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' enable
        # Wait for wallet to load; start if needed.
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded
        echo "Wallet db version is different; try again using a dumpwallet file."
        REPLY=''
        rm -rf "${TEMP_DIR_NAME1:?}"
      else
        break
      fi
    else
      if [[ $( grep -ic 'wallet dump' "${fullfile}" ) -gt 0 ]] || [[ $( grep -ic 'label=' "${fullfile}" ) -gt 0 ]]
      then
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' enable
        # Wait for wallet to load; start if needed.
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded
        if [[ -f "${HOME}/.pwd/${DATADIR_FILENAME}" ]]
        then
          _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' unlock_wallet_for_staking
        fi
        echo "Importing wallet dump file (Please Wait)"
        BASENAME=$( basename "${fullfile}" )
        # Put labeled addreses at the top.
        grep -i 'label=' "${fullfile}" | sudo tee "${CONF_DIR}/${BASENAME}.txt" >/dev/null
        grep -vi 'label=' "${fullfile}" | sudo tee -a "${CONF_DIR}/${BASENAME}.txt" >/dev/null
        sudo rm -f "${fullfile}"
        sudo chown "${USRNAME}":"${USRNAME}" "${CONF_DIR}/${BASENAME}.txt"
        sudo chmod 600 "${CONF_DIR}/${BASENAME}.txt"
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' importwallet "${CONF_DIR}/${BASENAME}.txt"
        sudo rm -f "${CONF_DIR}/${BASENAME}.txt"
        echo "Restarting wallet to update wallet.dat balance; will take some time."
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' disable
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' conf edit staking 1
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' start-recover
        # Wait for wallet to load; start if needed.
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded
        _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' enable
        break
      else
        echo "Unknown File."
        REPLY=''
        read -p "wallet.dat hasn't changed; try again (y/n)?: " -r
        REPLY=${REPLY,,} # tolower
        if [[ "${REPLY}" != 'y' ]]
        then
          break
        fi
      fi
    fi
  done
  rm -rf "${TEMP_DIR_NAME1:?}"

  rm -f "${HOME}/.pwd/${DATADIR_FILENAME}"

}

_setup_wallet_auto_pw () {
  if [[ ! -f "${TEMP_FILENAME1}" ]]
  then
    return
  fi
  read -r USRNAME CONF_FILE DAEMON_BIN CONTROLLER_BIN < "${TEMP_FILENAME1}"
  if [[ -z "${CONF_FILE}" ]]
  then
    return
  fi
  DATADIR=$( dirname "${CONF_FILE}" )
  DATADIR_FILENAME=$( echo "${DATADIR}" | tr '/' '_' )
  mkdir -p "${HOME}/.pwd/"

  # Load in functions.
  stty sane 2>/dev/null
  if [ -z "${PS1}" ]
  then
    PS1="\\"
  fi
  cd "${HOME}" || return 1 2>/dev/null
  # shellcheck disable=SC1090
  source "${HOME}/.bashrc"
  if [ "${PS1}" == "\\" ]
  then
    PS1=''
  fi
  stty sane 2>/dev/null

  # Install missing programs if needed.
  if [ ! -x "$( command -v aria2c )" ]
  then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq \
      curl \
      pwgen \
      ufw \
      lsof \
      util-linux \
      gzip \
      unzip \
      unrar \
      xz-utils \
      procps \
      jq \
      htop \
      git \
      gpw \
      bc \
      pv \
      sysstat \
      glances \
      psmisc \
      at \
      python3-pip \
      python-pip \
      subnetcalc \
      net-tools \
      sipcalc \
      python-yaml \
      html-xml-utils \
      apparmor \
      ack-grep \
      pcregrep \
      snapd \
      aria2 \
      dbus-user-session
  fi

  # Wait for wallet to load; start if needed.
  _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded

  # Wait for mnsync
  MNSYNC_WAIT_FOR='999'
  echo "Waiting for mnsync status..."
  echo "This can sometimes take up 10 minutes; please wait for mnsync."
  i=0
  while [[ $( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' mnsync status | grep -cF "${MNSYNC_WAIT_FOR}" ) -eq 0 ]]
  do
    PERCENT_DONE=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' daemon_log tail 2000 | grep -m 1 -o 'nSyncProgress.*\|Progress.*' | tr '=' ' ' | awk -v SF=100 '{printf($2*SF )}' )
    echo -e "\\r${SP:i++%${#SP}:1} Percent Done: %${PERCENT_DONE}      \\c"
    sleep 0.3
  done
  echo
  sudo true >/dev/null 2>&1

  # Try to unlock the wallet.
  _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' unlock_wallet_for_staking
  sleep 0.5

  # See if wallet is unlocked for staking.
  WALLET_UNLOCKED=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' getstakingstatus | jq '.walletunlocked' )

  while [[ "${WALLET_UNLOCKED}" != 'true' ]]
  do
    rm -f "${HOME}/.pwd/${DATADIR_FILENAME}" 2>/dev/null
    unset PASSWORD
    unset CHARCOUNT
    echo -n "Uploaded wallet.dat password: "
    stty -echo

    CHARCOUNT=0
    PROMPT=''
    CHAR=''
    while IFS= read -p "${PROMPT}" -r -s -n 1 CHAR
    do
      # Enter - accept password
      if [[ "${CHAR}" == $'\0' ]]
      then
        break
      fi
      # Backspace
      if [[ "${CHAR}" == $'\177' ]]
      then
        if [[ "${CHARCOUNT}" -gt 0 ]]
        then
          CHARCOUNT=$(( CHARCOUNT - 1 ))
          PROMPT=$'\b \b'
          PASSWORD="${PASSWORD%?}"
        else
          PROMPT=''
        fi
      else
        CHARCOUNT=$((CHARCOUNT+1))
        PROMPT='*'
        PASSWORD+="$CHAR"
      fi
    done
    stty echo

    echo
    touch "${HOME}/.pwd/${DATADIR_FILENAME}"
    chmod 600 "${HOME}/.pwd/${DATADIR_FILENAME}"
    echo "${PASSWORD}" > "${HOME}/.pwd/${DATADIR_FILENAME}"

    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' unlock_wallet_for_staking

    sleep 0.5
    WALLET_UNLOCKED=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' getstakingstatus | jq '.walletunlocked' )

  done
  unset PASSWORD
  unset CHARCOUNT

  # Add cronjob if needed.
  if [[ $( crontab -l 2>/dev/null | grep -cE "\"${USRNAME}\".*unlock_wallet_for_staking" 2>&1 ) -eq 0 ]]
  then
    MINUTES=$(( RANDOM % 60 ))
    ( crontab -l 2>/dev/null ; echo "${MINUTES} * * * * bash -ic 'source /var/multi-masternode-data/.bashrc; _masternode_dameon_2 \"${USRNAME}\" \"${CONTROLLER_BIN}\" \"\" \"${DAEMON_BIN}\" \"${CONF_FILE}\" \"\" \"-1\" \"-1\" unlock_wallet_for_staking 2>&1' 2>/dev/null" ) | crontab -
  fi

  echo
  echo "waiting 30s for staking status to change after unlocking."
  sleep 30

  # Wait for wallet to load; start if needed.
  _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded

  # Wait for mnsync
  MNSYNC_WAIT_FOR='999'
  echo "Waiting for mnsync status..."
  echo "This can sometimes take up 10 minutes; please wait for mnsync."
  i=0
  while [[ $( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' mnsync status | grep -cF "${MNSYNC_WAIT_FOR}" ) -eq 0 ]]
  do
    PERCENT_DONE=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' daemon_log tail 2000 | grep -m 1 -o 'nSyncProgress.*\|Progress.*' | tr '=' ' ' | awk -v SF=100 '{printf($2*SF )}' )
    echo -e "\\r${SP:i++%${#SP}:1} Percent Done: %${PERCENT_DONE}      \\c"
    sleep 0.3
  done

  # Restart node if staking isn't enabled.
  if [[ $( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' getstakingstatus | jq '.[]' | grep -c 'false' ) -eq 1 ]]
  then
    echo "Restarting the node"
    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' restart

    # Wait for wallet to load; start if needed.
    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded

    # Wait for mnsync
    MNSYNC_WAIT_FOR='999'
    echo "Waiting for mnsync status..."
    echo "This can sometimes take up 10 minutes; please wait for mnsync."
    i=0
    while [[ $( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' mnsync status | grep -cF "${MNSYNC_WAIT_FOR}" ) -eq 0 ]]
    do
      PERCENT_DONE=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' daemon_log tail 2000 | grep -m 1 -o 'nSyncProgress.*\|Progress.*' | tr '=' ' ' | awk -v SF=100 '{printf($2*SF )}' )
      echo -e "\\r${SP:i++%${#SP}:1} Percent Done: %${PERCENT_DONE}      \\c"
      sleep 0.3
    done
    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' unlock_wallet_for_staking
    echo "waiting 30s for staking status to change after unlocking."
    sleep 30
  fi

  # Output info.
  echo
  WALLET_BALANCE=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' getbalance )
  STAKE_INPUTS=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' liststakeinputs )
  STAKING_BALANCE=$( echo "${STAKE_INPUTS}" | jq '.[].amount' 2>/dev/null | awk '{s+=$1} END {print s}' 2>/dev/null )
  STAKING_INPUTS_COUNT=$( echo "${STAKE_INPUTS}" | grep -c 'amount' )
  echo -e "Current wallet.dat balance: \e[1m${WALLET_BALANCE}\e[0m"
  echo -e "Value of coins that can stake: \e[1m${STAKING_BALANCE}\e[0m"
  echo -e "Number of staking inputs: \e[1m${STAKING_INPUTS_COUNT}\e[0m"
  echo "Node info: ${USRNAME} ${CONF_FILE}"
  echo "Staking Status:"
  _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' getstakingstatus | grep -C 20 --color -E '^|.*false'
  CONF_FILE_BASENAME=$( basename "${CONF_FILE}" )
  echo
  echo
  echo
  echo "Start or Restart your desktop wallet after adding the line below to the"
  echo "desktop wallet's conf file ${CONF_FILE_BASENAME}. You can edit it from "
  echo "the desktop wallet by going to Tools -> Open Wallet Configuration File"
  echo
  echo "staking=0"
  echo

}

_discord_warning () {
  read -n 1 -s -r -p "Press any key (like enter) to continue"
  echo
  echo
  echo "If you get a Direct Message from anyone who appears to be on the team"
  echo "odds are it's a scammer."
  sleep 3
  echo "The Energi team will only talk to in the energi server,"
  echo "never via direct private message."
  sleep 3
  echo "We will not friend request you."
  sleep 3
  echo "None of us run private staking or masternode pools or offer OTC deals."
  sleep 3
  read -n 1 -s -r -p "Press any key (like enter) to continue"
  echo
  echo "Usernames on discord are not unique."
  sleep 3
  echo "This means a DM may appear to be from a team member "
  echo "(even matching the #1234)!"
  sleep 3
  echo "A quick way to check if your talking to a scammer is to "
  echo "view the profile and check mutual servers,"
  sleep 4
  echo "if Energi isn't listed they are 100% a scammer."
  echo "If they have the the nitro logo, they are a scammer."
  sleep 4
  read -n 1 -s -r -p "Press any key (like enter) to continue"
  echo
  echo -e "if you get a \e[1;4mDirect Private Message\e[0m from"
  echo "TommyWorldPower#8217"
  sleep 2
  echo "Ryan Lucchese#9615"
  sleep 2
  echo "mcarper#0918"
  sleep 2
  echo "or any other person on the energi team, please report it to the"
  echo "#help-desk discord support channel."
  sleep 3
  echo "Odds are very high you are talking to a scammer."
  sleep 3
  read -n 1 -s -r -p "Press any key (like enter) to continue"
  echo
  echo "If the color of the user that you're talking to isn't "
  echo -e "\e[32m\e[7mgreen\e[0m, \e[36m\e[7mblue\e[0m, \e[33m\e[7myellow\e[0m, or \e[31m\e[7mred\e[0m you're not on the energi server."
  sleep 4
  echo "Don't talk to them; they are trying to scam you."
  sleep 3
  echo "please report it to the #help-desk discord support channel."
  sleep 3
  read -n 1 -s -r -p "Press any key (like enter) to continue"
  echo
  echo

}

_restrict_logins
_check_clock
_setup_two_factor
_copy_wallet '' '' 'energid' ''
_setup_wallet_auto_pw
_discord_warning

rm -rf "${TEMP_FILENAME1}"
