
TEMP_FILENAME1=$( mktemp )

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
  fi
  if [[ -z "${BOTH_LISTS}" ]]
  then
    echo "User login can not be restricted."
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
  if [[ ! -s "${HOME}/.google_authenticator" ]]
    then
    REPLY=''
    read -p "Require 2 factor authentication code for password SSH login (y/n)?: " -r
    REPLY=${REPLY,,} # tolower
    if [[ "${REPLY}" == 'n' ]]
    then
      return
    fi
    
  else
    REPLY=''
    read -p "Review 2 factor authentication code for password SSH login (y/n)?: " -r
    if [[ "${REPLY}" == 'n' ]] || [[ -z "${REPLY}" ]]
    then
      return
    fi
  fi
  
  # Install google-authenticator if not there.
  if [ ! -x "$( command -v google-authenticator )" ]
  then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq libpam-google-authenticator
  fi
  if [ ! -x "$( command -v php )" ]
  then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq php
  fi
  if [ ! -x "$( command -v qrencode )" ]
  then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq qrencode
  fi
  wget -4qo- https://raw.githack.com/mikeytown2/masternode/master/stake/otp.php -O /tmp/___otp.php

  # Generate otp.
  IP_ADDRESS=$( hostname -i | cut -d ' ' -f1 )
  USRNAME=$( whoami )
  UP=$( tput cuu1 )
  stty sane 2>/dev/null
  OUTPUT=0
  if [[ -s "${HOME}/.google_authenticator" ]]
  then
    echo "${HOME}/.google_authenticator already exists."
    SECRET=$( head -n 1 "${HOME}/.google_authenticator" )
    REPLY=''
    read -p "Display QR code again (y/n)?: " -r
    REPLY=${REPLY,,} # tolower
    if [[ "${REPLY}" == 'y' ]]
    then
      echo "Warning: pasting the following URL into your browser exposes the OTP secret to Google:"
      echo "https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=otpauth://totp/ssh%2520login%2520for%2520'${USRNAME}'%3Fsecret%3D${SECRET}%26issuer%3D${IP_ADDRESS}"
      qrencode -l L -m 2 -t UTF8 "otpauth://totp/ssh%20login%20for%20'${USRNAME}'?secret=${SECRET}&issuer=${IP_ADDRESS}"
      echo "Your secret key is: ${SECRET}"
      OUTPUT=1
    fi
  else
    OUTPUT=1
    sudo google-authenticator -t -d -f -r 10 -R 30 -w 5 -e 1 -Q UTF8 -l "ssh login for '${USRNAME}'" -i "${IP_ADDRESS}"
    # Clean up output.
    echo -e "${UP}\\c"
    echo -e "${UP}\\c"
    echo -e "${UP}\\c"
    echo "                                   "
    echo "                                   "
    echo "                                   "
    echo -e "${UP}\\c"
    echo -e "${UP}\\c"
    echo -e "${UP}\\c"
    echo "Please scan in the QR code."
    # Add 9 recovery digits.
    {
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    head -200 /dev/urandom | cksum | tr -d ' ' | cut -c1-8 ;
    } >> "${HOME}/.google_authenticator"
  fi

  # Validate otp.
  REPLY=''
  while [[ -z "${REPLY}" ]] || [[ "$( php /tmp/___otp.php "${REPLY}" | grep -c 'Key Verified' )" -eq 0 ]]
  do
    REPLY=''
    read -p "6 digit verification code (leave blank to disable & delete): " -r
    if [[ -z "${REPLY}" ]]
    then
      rm -f "${HOME}/.google_authenticator"
      return
    fi
    if [[ "${OUTPUT}" -eq 1 ]]
    then
      echo "Your emergency scratch codes are:"
      tail -n 10 "${HOME}/.google_authenticator" | awk '{print "  " $1 }'
    fi
  done
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
    echo "Login again."
    echo "If using Bitvise select keyboard-interactive with no submethods selected."
    echo
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

  # Install ffsend.
  if [ ! -x "$( command -v snap )" ]
  then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq snap
  fi
  if [ ! -x "$( command -v ffsend )" ]
  then
    sudo snap install ffsend
  fi

  # Load in functions.
  stty sane 2>/dev/null
  if [ -z "${PS1}" ]
  then
    PS1="\\"
  fi
  cd ~ || return 1 2>/dev/null
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
    if [[ -z "${CONF_FILE}" ]]
    then
      CONF_FILE=$( "${USRNAME}" conf loc )
    fi
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
  fi

  # Get info the hard way.
  if [[ -z "${CONF_FILE}" ]] || [[ -z "${DAEMON_BIN}" ]] || [[ -z "${CONTROLLER_BIN}" ]]
  then
    LSLOCKS_OUTPUT=$( sudo lslocks | grep -oE ".*/blocks" | sed 's/blocks$//g' )
    if [[ -z "${LSLOCKS_OUTPUT}" ]]
    then
      return
    fi

    RUNNING_NODES=$( echo "${LSLOCKS_OUTPUT}" | awk '{print $1 " " $9 }' )
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
  if [[ -z "${USRNAME}" ]] || [[ -z "${CONF_FILE}" ]] || [[ -z "${CONTROLLER_BIN}" ]]
  then
    if [[ ! -z "${DAEMON_BIN}" ]]
    then
      echo "Install a new ${DAEMON_BIN} node on this vps?"
      REPLY=''
      read -p "Display QR code again (y/n)?: " -r
      REPLY=${REPLY,,} # tolower
      if [[ "${REPLY}" == 'y' ]]
      then
        bash -ic "$(wget -4qO- -o- "raw.githubusercontent.com/mikeytown2/masternode/master/${DAEMON_BIN}.sh")" -- NO_MN
        # shellcheck disable=SC1090
        source "${HOME}/.bashrc"
        _get_node_info "${USRNAME}" "${CONF_FILE}" "${DAEMON_BIN}" "${CONTROLLER_BIN}"
        return
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

  echo
  echo "Target: ${CONF_DIR}"
  echo "Please encrypted your wallet.dat file before uploading it to"
  echo "https://send.firefox.com/"
  echo "Paste in the url to your wallet.dat file."
  echo
  REPLY=''
  while [[ -z "${REPLY}" ]] || [[ "$( echo "${REPLY}" | grep -c 'https://send.firefox.com/download/' )" -eq 0 ]]
  do
    read -p "URL (leave blank do it manually (sftp/scp)): " -r
    if [[ -z "${REPLY}" ]]
    then
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' stop
      echo "Please Copy the wallet.dat file to ${CONF_DIR}/wallet.dat on your own"
      read -p "Press Enter Once Done: " -r
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' start
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded
      return
    fi
  done

  TEMP_DIR_NAME1=$( mktemp -d -p "${HOME}" )
  ffsend download -y --verbose "${REPLY}" -o "${TEMP_DIR_NAME1}/"
  fullfile=$( find "${TEMP_DIR_NAME1}/" -type f )
  if [[ $( echo "${fullfile}" | grep -c 'wallet.dat' ) -gt 0 ]]
  then
    echo "Moving wallet.dat file"
    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' stop
    mv "${CONF_DIR}/wallet.dat" "${CONF_DIR}/wallet.dat.bak"
    mv "${fullfile}" "${CONF_DIR}/wallet.dat"
    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' start
    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' wait_for_loaded
  else
    if [[ $( grep -ic 'wallet dump' "${fullfile}" ) -gt 0 ]]
    then
      echo "Importing wallet dump file (Please Wait)"
      _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' importwallet "${fullfile}"
    else
      echo "Unknown File."
    fi
  fi

  rm -rf "${TEMP_DIR_NAME1:?}"
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
  mkdir -p "/${HOME}/.pwd/"

  # Load in functions.
  stty sane 2>/dev/null
  if [ -z "${PS1}" ]
  then
    PS1="\\"
  fi
  cd ~ || return 1 2>/dev/null
  # shellcheck disable=SC1090
  source "${HOME}/.bashrc"
  if [ "${PS1}" == "\\" ]
  then
    PS1=''
  fi
  stty sane 2>/dev/null

  # Try to unlock the wallet.
  _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' unlock_wallet_for_staking
  sleep 0.5

  # See if wallet is unlocked for staking.
  WALLET_UNLOCKED=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' getstakingstatus | jq '.walletunlocked' )

  while [[ "${WALLET_UNLOCKED}" != 'true' ]]
  do
    REPLY=''
    read -p "Wallet Password (leave blank skip): " -r
    if [[ -z "${REPLY}" ]]
    then
      return
    fi
    _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' walletpassphrase "${REPLY}" 9999999999 true

    sleep 0.5
    WALLET_UNLOCKED=$( _masternode_dameon_2 "${USRNAME}" "${CONTROLLER_BIN}" '' "${DAEMON_BIN}" "${CONF_FILE}" '' '-1' '-1' getstakingstatus | jq '.walletunlocked' )
    if [[ "${WALLET_UNLOCKED}" == 'true' ]]
    then
      touch "/${HOME}/.pwd/${DATADIR_FILENAME}"
      chmod 600 "/${HOME}/.pwd/${DATADIR_FILENAME}"
      echo "${REPLY}" > "/${HOME}/.pwd/${DATADIR_FILENAME}"
    fi
  done

  # Add cronjob if needed.
  if [[ $( crontab -l 2>/dev/null | grep -cE "\"${USRNAME}\".*unlock_wallet_for_staking" 2>&1 ) -eq 0 ]]
  then
    MINUTES=$(( RANDOM % 60 ))
    ( crontab -l 2>/dev/null ; echo "${MINUTES} * * * * bash -ic 'source /var/multi-masternode-data/.bashrc; _masternode_dameon_2 \"${USRNAME}\" \"${CONTROLLER_BIN}\" \"\" \"${DAEMON_BIN}\" \"${CONF_FILE}\" \"\" \"-1\" \"-1\" unlock_wallet_for_staking 2>&1' 2>/dev/null" ) | crontab -
  fi
}

_restrict_logins
_check_clock
_setup_two_factor
_copy_wallet '' '' 'energid' ''
_setup_wallet_auto_pw

rm -rf "${TEMP_FILENAME1}"
