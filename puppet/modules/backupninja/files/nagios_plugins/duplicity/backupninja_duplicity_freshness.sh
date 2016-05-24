#!/bin/bash
# -*- mode: sh; sh-basic-offset: 3; indent-tabs-mode: nil; -*-
# vim: set filetype=sh sw=3 sts=3 expandtab autoindent:

# Load backupninja library/helpers, because why reinventing the wheel? [Because my wheels weren't round]
# some duplication is to be expected
# this is only supposed to work with duplicity

## Functions
# simple lowercase function
function tolower() {
   echo "$1" | tr '[:upper:]' '[:lower:]'
}

# we grab the current time once, since processing
# all the configs might take more than an hour.
nowtime=`LC_ALL=C date +%H`
nowday=`LC_ALL=C date +%d`
nowdayofweek=`LC_ALL=C date +%A`
nowdayofweek=`tolower "$nowdayofweek"`

conffile="/etc/backupninja.conf"

# find $libdirectory
libdirectory=`grep '^libdirectory' $conffile | /usr/bin/awk '{print $3}'`
if [ -z "$libdirectory" ]; then
   if [ -d "/usr/lib/backupninja" ]; then
      libdirectory="/usr/lib/backupninja"
   else
      echo "Could not find entry 'libdirectory' in $conffile."
      fatal "Could not find entry 'libdirectory' in $conffile."
   fi
else
   if [ ! -d "$libdirectory" ]; then
      echo "Lib directory $libdirectory not found."
      fatal "Lib directory $libdirectory not found."
   fi
fi

. $libdirectory/tools

setfile $conffile

# get global config options (second param is the default)
getconf configdirectory /etc/backup.d
getconf scriptdirectory /usr/share/backupninja
getconf reportdirectory
getconf reportemail
getconf reporthost
getconf reportspace
getconf reportsuccess yes
getconf reportinfo no
getconf reportuser
getconf reportwarning yes
getconf loglevel 3
getconf when "Everyday at 01:00"
defaultwhen=$when
getconf logfile /var/log/backupninja.log
getconf usecolors "yes"
getconf SLAPCAT /usr/sbin/slapcat
getconf LDAPSEARCH /usr/bin/ldapsearch
getconf RDIFFBACKUP /usr/bin/rdiff-backup
getconf CSTREAM /usr/bin/cstream
getconf MYSQLADMIN /usr/bin/mysqladmin
getconf MYSQL /usr/bin/mysql
getconf MYSQLHOTCOPY /usr/bin/mysqlhotcopy
getconf MYSQLDUMP /usr/bin/mysqldump
getconf PGSQLDUMP /usr/bin/pg_dump
getconf PGSQLDUMPALL /usr/bin/pg_dumpall
getconf PGSQLUSER postgres
getconf GZIP /bin/gzip
getconf GZIP_OPTS --rsyncable
getconf RSYNC /usr/bin/rsync
getconf admingroup root

if [ ! -d "$configdirectory" ]; then
   echo "Configuration directory '$configdirectory' not found."
   fatal "Configuration directory '$configdirectory' not found."
fi

# get the duplicity configuration
function get_dupconf(){
   setfile $1
   getconf options
   getconf testconnect yes
   getconf nicelevel 0
   getconf tmpdir
   
   setsection gpg
   getconf password
   getconf sign no
   getconf encryptkey
   getconf signkey
   
   setsection source
   getconf include
   getconf vsnames all
   getconf vsinclude
   getconf exclude
   
   setsection dest
   getconf incremental yes
   getconf increments 30
   getconf keep 60
   getconf keepincroffulls all
   getconf desturl
   getconf awsaccesskeyid
   getconf awssecretaccesskey
   getconf cfusername
   getconf cfapikey
   getconf cfauthurl
   getconf ftp_password
   getconf sshoptions
   getconf bandwidthlimit 0
   getconf desthost
   getconf destdir
   getconf destuser
   destdir=${destdir%/}
}

### some voodoo to mangle the correct commands

function mangle_cli(){

   execstr_options="$options "
   execstr_source=
   if [ -n "$desturl" ]; then
      [ -z "$destuser" ] || warning 'the configured destuser is ignored since desturl is set'
      [ -z "$desthost" ] || warning 'the configured desthost is ignored since desturl is set'
      [ -z "$destdir" ] || warning 'the configured destdir is ignored since desturl is set'
      execstr_serverpart="$desturl"
   else
      execstr_serverpart="scp://$destuser@$desthost/$destdir"
   fi
   
   
   ### Symmetric or asymmetric (public/private key pair) encryption
   if [ -n "$encryptkey" ]; then
      execstr_options="${execstr_options} --encrypt-key $encryptkey"
   fi
   
   ### Data signing (or not)
   if [ "$sign" == yes ]; then
      # duplicity is not able to sign data when using symmetric encryption
      [ -n "$encryptkey" ] || fatal "The encryptkey option must be set when signing."
      # if needed, initialize signkey to a value that is not empty (checked above)
      [ -n "$signkey" ] || signkey="$encryptkey"
      execstr_options="${execstr_options} --sign-key $signkey"
   fi
   
   ### Temporary directory
   precmd=
   if [ -n "$tmpdir" ]; then
      if [ ! -d "$tmpdir" ]; then
         #info "Temporary directory ($tmpdir) does not exist, creating it."
         mkdir -p "$tmpdir"
         [ $? -eq 0 ] || fatal "Could not create temporary directory ($tmpdir)."
         chmod 0700 "$tmpdir"
      fi
      #info "Using $tmpdir as TMPDIR"
      precmd="${precmd}TMPDIR=$tmpdir "
   fi
   
   ### Source
   
   set -o noglob
   
   # excludes
   SAVEIFS=$IFS
   IFS=$(echo -en "\n\b")
   for i in $exclude; do
      str="${i//__star__/*}"
      execstr_source="${execstr_source} --exclude '$str'"
   done
   IFS=$SAVEIFS
   
   # includes
   SAVEIFS=$IFS
   IFS=$(echo -en "\n\b")
   for i in $include; do
      [ "$i" != "/" ] || fatal "Sorry, you cannot use 'include = /'"
      str="${i//__star__/*}"
      execstr_source="${execstr_source} --include '$str'"
   done
   IFS=$SAVEIFS
   
   set +o noglob
   
   execstr_options="${execstr_options} --ssh-options '$sshoptions'"
   if [ "$bandwidthlimit" != 0 ]; then
      [ -z "$desturl" ] || warning 'The bandwidthlimit option is not used when desturl is set.'
      execstr_precmd="trickle -s -d $bandwidthlimit -u $bandwidthlimit"
   fi
}

#function findlastdates(){
#   outputfile=$1
#   lastfull=0
#   lastinc=0
#   backuptime=0
#   
#   while read line; do
#      atime=0
#      arr=()
#      sort=''
#      test=$(echo $line|awk '{if (NF == 7); if ($1 == "Full" || $1 == "Incremental") {print $4, $3, $6, $5}}'  )
#   
#      if [ -n "$test"  ]; then
#         backuptime=$(date -u -d "$test" +%s)
#   
#         arr=($(echo $line|awk '{print $1, $2, $3, $4, $5, $6}'))
#         if [ ${arr[0]} == "Incremental" ] && [ "$lastinc" -lt "$backuptime" ] ; then
#            lastinc=$backuptime
#         elif [ ${arr[0]} == "Full" ] && [ "$lastfull" -lt "$backuptime" ] ; then
#            lastfull=$backuptime
#         fi
#   
#      fi
#   
#   done < $outputfile
#      # a full backup can be seen as incremental too
#      lastinc=$(echo $lastinc | awk 'max=="" || $1 > max {max=$1} END{ print max}')
#}

function check_status() {
   grep -q 'No orphaned or incomplete backup sets found.' $1
   if [ $? -ne 0 ] ; then
     exit 2
   fi
}

##
## this function handles the freshness check of a backup action
##

function process_action() {
   local file="$1"
   local suffix="$2"
   setfile $file
   get_dupconf $1
   mangle_cli
   
   outputfile=`maketemp backupout`
   export PASSPHRASE=$password
   export FTP_PASSWORD=$ftp_password
   output=` su -c \
            "$execstr_precmd duplicity $execstr_options collection-status $execstr_serverpart >$outputfile 2>&1"`
   exit_code=$?
   echo -n $outputfile

   #check_status
   #findlastdates
}

files=`find $configdirectory -follow -mindepth 1 -maxdepth 1 -type f ! -name '.*.swp' | sort -n`

for file in $files; do
   [ -f "$file" ] || continue
   suffix="${file##*.}"
   base=`basename $file`
   if [ "${base:0:1}" == "0" -o "$suffix" == "disabled" ]; then
      continue
   fi
   if [ -e "$scriptdirectory/$suffix" -a "$suffix" == "dup" ]; then
      process_action $file $suffix
   fi
done

