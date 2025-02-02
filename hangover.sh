#!/bin/sh -e

# Get User
USER=whoami

# Exit early if any session with my username is found
if who | grep -wq $USER; then
  exit
fi

# Get user home path and username
PATH=~

# Checks to see if job is in crontab already and if not updates cronto run the script only on weekdays @ 8:45am
if ! crontab -u $USER -l | grep hangover.sh then
  echo "45 8 * * 1-5 $PATH/hangover.sh" >> /etc/crontab
fi

# Phone numbers
MY_NUMBER='+xxx'
NUMBER_OF_BOSS='+xxx'

EXCUSES=(
  'Locked out'
  'Pipes broke'
  'Food poisoning'
  'Not feeling well'
)
rand=$[ $RANDOM % ${#EXCUSES[@]} ]

RANDOM_EXCUSE=${EXCUSES[$rand]}
MESSAGE="Gonna work from home. "$RANDOM_EXCUSE

# Send a text message
RESPONSE=`curl -fSs -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN" \
  -d "From=$MY_NUMBER" -d "To=$NUMBER_OF_BOSS" -d "Body=$MESSAGE" \
  "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages"`

# Log errors
if [ $? -gt 0 ]; then
  echo "Failed to send SMS: $RESPONSE"
  exit 1
fi
