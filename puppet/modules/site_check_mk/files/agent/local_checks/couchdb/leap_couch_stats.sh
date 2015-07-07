#!/bin/bash
#
# todo:
#  - thresholds
#  - couch response time
#  - make CURL/URL/DBLIST_EXCLUDE vars configurable
#  - move load_nagios_utils() to helper library so we can use it from multiple scripts

start_time=$(date +%s.%N)

CURL='curl -s --netrc-file /etc/couchdb/couchdb.netrc'
URL='http://127.0.0.1:5984'
TMPFILE=$(mktemp)
DBLIST_EXCLUDE='(user-|sessions_|tokens_)'
PREFIX='Couchdb_'


load_nagios_utils () {
  # load the nagios utils
  # in debian, the package nagios-plugins-common installs utils.sh to /usr/lib/nagios/plugins/utils.sh
  utilsfn=
  for d in $PROGPATH /usr/lib/nagios/plugins /usr/lib64/nagios/plugins /usr/local/nagios/libexec /opt/nagios-plugins/libexec . ; do
    if [ -f "$d/utils.sh" ]; then
      utilsfn=$d/utils.sh;
    fi
  done
  if [ "$utilsfn" = "" ]; then
    echo "UNKNOWN - cannot find utils.sh (part of nagios plugins)";
    exit 3;
  fi
  . "$utilsfn";
  STATE[$STATE_OK]='OK'
  STATE[$STATE_WARNING]='Warning'
  STATE[$STATE_CRITICAL]='Critical'
  STATE[$STATE_UNKNOWN]='Unknown'
  STATE[$STATE_DEPENDENT]='Dependend'
}

get_global_stats_perf () {
  trap "localexit=3" ERR
  local localexit db_count
  localexit=0

  # get a list of all dbs
  $CURL -X GET $URL/_all_dbs | json_pp | egrep -v '(\[|\])' > $TMPFILE

  db_count=$( wc -l < $TMPFILE)
  excluded_db_count=$( egrep -c "$DBLIST_EXCLUDE" $TMPFILE )

  echo "db_count=$db_count|excluded_db_count=$excluded_db_count"
  return ${localexit}
}

db_stats () {
  trap "localexit=3" ERR
  local db db_stats doc_count del_doc_count localexit
  localexit=0

  db="$1"
  name="$2"

  if [ -z "$name" ]
  then
    name="$db"
  fi

  perf="$perf|${db}_docs=$( $CURL -s -X GET ${URL}/$db | json_pp |grep 'doc_count' | sed 's/[^0-9]//g' )"
  db_stats=$( $CURL -s -X GET ${URL}/$db | json_pp )

  doc_count=$( echo "$db_stats" | grep 'doc_count' | grep -v 'deleted_doc_count' | sed 's/[^0-9]//g' )
  del_doc_count=$( echo "$db_stats" | grep 'doc_del_count' | sed 's/[^0-9]//g' )

  # don't divide by zero
  if [ $del_doc_count -eq 0 ]
  then
    del_doc_perc=0
  else
    del_doc_perc=$(( del_doc_count * 100 / doc_count ))
  fi

  bytes=$( echo "$db_stats" | grep disk_size | sed 's/[^0-9]//g' )
  disk_size=$( echo "scale = 2; $bytes / 1024 / 1024" | bc -l )

  echo -n "${localexit} ${PREFIX}${name}_database ${name}_docs=$doc_count|${name}_deleted_docs=$del_doc_count|${name}_deleted_docs_percentage=${del_doc_perc}%"
  printf "|${name}_disksize_mb=%02.2fmb ${STATE[localexit]}: database $name\n" "$disk_size"

  return ${localexit}
}

# main

load_nagios_utils

# per-db stats
# get a list of all dbs
$CURL -X GET $URL/_all_dbs | json_pp | egrep -v '(\[|\])' > $TMPFILE

# get list of dbs to check
dbs=$( egrep -v "${DBLIST_EXCLUDE}" $TMPFILE | tr -d '\n"' | sed 's/,/ /g' )
rm "$TMPFILE"

for db in $dbs
do
  db_stats "$db"
done

# special handling for rotated dbs
suffix=$(($(date +'%s') / (60*60*24*30) + 1))
db_stats "sessions_${suffix}" "sessions"
db_stats "tokens_${suffix}" "tokens"


# show global couchdb stats
global_stats_perf=$(get_global_stats_perf)
exitcode=$?

end_time=$(date +%s.%N)
duration=$( echo "scale = 2; $end_time - $start_time" | bc -l )

printf "${exitcode} ${PREFIX}global_stats ${global_stats_perf}|script_duration=%02.2fs ${STATE[exitcode]}: global couchdb status\n" "$duration"
