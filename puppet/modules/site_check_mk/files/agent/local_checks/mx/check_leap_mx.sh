#!/bin/bash


WARN=1
CRIT=5

# in minutes
MAXAGE=10

STATUS[0]='OK'
STATUS[1]='Warning'
STATUS[2]='Critical'
CHECKNAME='Leap_MX_Queue'

WATCHDIR='/var/mail/vmail/Maildir/new/'


total=`find $WATCHDIR -type f -mmin +$MAXAGE | wc -l`

if [ $total -lt $WARN ]
then
  exitcode=0
else
  if [ $total -le $CRIT ]
  then
    exitcode=1
  else
      exitcode=2
  fi
fi

echo "${exitcode} ${CHECKNAME} stale_files=${total} ${STATUS[exitcode]}: ${total} stale files (>=${MAXAGE} min) in ${WATCHDIR}."

