#!/bin/bash

WEBHOOK_USERNAME_DEFAULT='Masternode Monitor'
WEBHOOK_AVATAR_DEFAULT='https://i.imgur.com/8WHSSa7s.jpg'

# Get sqlite.
if ! [ -x "$(command -v sqlite3 )" ]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq sqlite3
fi
sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db <<EOF
CREATE TABLE IF NOT EXISTS webhook_urls (
 type TEXT PRIMARY KEY,
 url TEXT NOT NULL
);
EOF


INSTALL_MN_MON_SERVICE () {
cat << SYSTEMD_CONF | sudo tee /etc/systemd/system/mnbot.service >/dev/null

[Unit]
Description=${DAEMON_NAME} ${MASTERNODE_NAME} for user ${USRNAME}
After=syslog.target network.target

[Service]
SyslogIdentifier=cftimer-test-energi-sentinel
Type=oneshot
Restart=no
RestartSec=5
UMask=0027
ExecStart=/bin/bash /var/multi-masternode-data/mnbot/mnmon.sh


[Timer]
OnBootSec=60
OnUnitActiveSec=60


SYSTEMD_CONF
}

WEBHOOK_SEND () {
URL="${1}"
DESCRIPTION="${2}"
TITLE="${3}"
WEBHOOK_USERNAME="${4}"
if [[ -z "${WEBHOOK_USERNAME}" ]]
then
  WEBHOOK_USERNAME="${WEBHOOK_USERNAME_DEFAULT}"
fi
WEBHOOK_AVATAR="${5}"
if [[ -z "${WEBHOOK_AVATAR}" ]]
then
  WEBHOOK_AVATAR="${WEBHOOK_AVATAR_DEFAULT}"
fi
WEBHOOK_COLOR="${6}"

_PAYLOAD=$( cat << PAYLOAD
{"username": "${WEBHOOK_USERNAME}",
  "avatar_url": "${WEBHOOK_AVATAR}",
  "embeds": [
    {
      "title": "${TITLE}",
      "color": ${WEBHOOK_COLOR},
      "description": "${DESCRIPTION}"
    }
  ]
}
PAYLOAD
)

curl -H "Content-Type: application/json" \
-X POST \
-d "${_PAYLOAD}" "${URL}"

}


WEBHOOK_SEND_ERROR () {
URL=$( sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "select url from webhook_urls WHERE type = 'Error';" )
DESCRIPTION="${1}"
if [[ -z "${DESCRIPTION}" ]]
then
  DESCRIPTION="Error!"
fi
TITLE="${2}"
if [[ -z "${TITLE}" ]]
then
  TITLE=":exclamation: Error :exclamation:"
fi
WEBHOOK_COLOR="${5}"
if [[ -z "${WEBHOOK_COLOR}" ]]
then
  WEBHOOK_COLOR=16711680
fi

WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
}

WEBHOOK_SEND_WARNING () {
URL=$( sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "select url from webhook_urls WHERE type = 'Warning';" )
DESCRIPTION="${1}"
if [[ -z "${DESCRIPTION}" ]]
then
  DESCRIPTION="Warning."
fi
TITLE="${2}"
if [[ -z "${TITLE}" ]]
then
  TITLE=":warning: Warning :warning:"
fi
WEBHOOK_COLOR="${5}"
if [[ -z "${WEBHOOK_COLOR}" ]]
then
  WEBHOOK_COLOR=16776960
fi

WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
}

WEBHOOK_SEND_INFO () {
URL=$( sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "select url from webhook_urls WHERE type = 'Information';" )
DESCRIPTION="${1}"
if [[ -z "${DESCRIPTION}" ]]
then
  DESCRIPTION="Information."
fi
TITLE="${2}"
if [[ -z "${TITLE}" ]]
then
  TITLE=":blue_book: Information :blue_book:"
fi
WEBHOOK_COLOR="${5}"
if [[ -z "${WEBHOOK_COLOR}" ]]
then
  WEBHOOK_COLOR=65535
fi

WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
}

WEBHOOK_SEND_SUCCESS () {
URL=$( sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "select url from webhook_urls WHERE type = 'Success';" )
DESCRIPTION="${1}"
if [[ -z "${DESCRIPTION}" ]]
then
  DESCRIPTION="Success!"
fi
TITLE="${2}"
if [[ -z "${TITLE}" ]]
then
  TITLE=":moneybag: Success :money_mouth:"
fi
WEBHOOK_COLOR="${5}"
if [[ -z "${WEBHOOK_COLOR}" ]]
then
  WEBHOOK_COLOR=65535
fi

WEBHOOK_SEND "${URL}" "${DESCRIPTION}" "${TITLE}" "${3}" "${4}" "${WEBHOOK_COLOR}"
}

WEBHOOK_URL_PROMPT () {
TEXT_A="${1}"
WEBHOOKURL="${2}"

# Get jq.
if ! [ -x "$(command -v jq)" ]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq jq
fi

# Get webhook url.
echo
echo -n 'Get Webhook URL: Your personal server (press plus on left if you do not have one)'
echo -n ' -> text channels, general, click gear to "edit channel" -> Left side select Webhooks'
echo -n ' -> Create Webhook -> Copy webhook url -> save'
echo
echo "This webhook will be used for ${TEXT_A} Messages."
echo 'You can reuse the same webhook url if you want all alerts and information'
echo 'pings in the same channel.'
echo

while :
do
  read -e -i "$WEBHOOKURL" -p "${TEXT_A}s WebHook URL: " input
  WEBHOOKURL="${input:-$WEBHOOKURL}"

  if [[ ! -z "${WEBHOOKURL}" ]]
  then
    TOKEN=$( wget -qO- -o- "${WEBHOOKURL}" | jq -r '.token' )
    if [[ -z "$TOKEN" ]]
    then
      echo "Given URL is not a webhook."
      echo
      echo -n 'Get Webhook URL: Your personal server (press plus on left if you do not have one)'
      echo -n ' -> Right click on your server -> Server Settings -> Webhooks'
      echo -n ' -> Create Webhook -> Copy webhook url -> save'
      echo
      WEBHOOKURL=''
    else
      break
    fi
  fi
done

sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "insert into webhook_urls (type,url) values ('${TEXT_A}','${WEBHOOKURL}');"
}

WEBHOOKURL=$( sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "select url from webhook_urls WHERE type = 'Error';" )
if [[ -z "${WEBHOOKURL}" ]]
then
  WEBHOOK_URL_PROMPT "Error"
  WEBHOOK_SEND_ERROR "Test"
fi
WEBHOOKURL=$( sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "select url from webhook_urls WHERE type = 'Warning';" )
if [[ -z "${WEBHOOKURL}" ]]
then
  WEBHOOK_URL_PROMPT "Warning"
  WEBHOOK_SEND_WARNING "Test"
fi
WEBHOOKURL=$( sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "select url from webhook_urls WHERE type = 'Information';" )
if [[ -z "${WEBHOOKURL}" ]]
then
  WEBHOOK_URL_PROMPT "Information"
  WEBHOOK_SEND_INFO "Test"
fi
WEBHOOKURL=$( sqlite3 -batch /var/multi-masternode-data/mnbot/mnmon.sqlite3.db "select url from webhook_urls WHERE type = 'Success';" )
if [[ -z "${WEBHOOKURL}" ]]
then
  WEBHOOK_URL_PROMPT "Success"
  WEBHOOK_SEND_SUCCESS "Test"
fi
