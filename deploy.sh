#!/bin/sh
# 
# missing: header, license

bad_usage() { usage 1>&2; [ $# -eq 0 ] || echo "$@"; exit 1; }

usage() {
       cat <<EOF

Usage: ${0##*/} [--init]

  Configures Leap services as defined from ../config/default.yaml

  options:
    --init          Install dependencies, should be run once at the first time. 

EOF
}

install_prerequisites () {
  PACKAGES='git puppet ruby-hiera-puppet'
  echo "Installing $PACKAGES, configuring some basic puppet requirements."
  dpkg -l $PACKAGES > /dev/null 2>&1
  if [ ! $? -eq 0 ]
  then 
    apt-get update
    apt-get install $PACKAGES 
  fi

  # lsb is needed for a first puppet run
  puppet apply $PUPPET_ENV --execute 'include lsb'
}


# main 

PUPPET_ENV='--confdir=puppet'

long_opts="init"
getopt_out=$(getopt --name "${0##*/}" \
       --options "${short_opts}" --long "${long_opts}" -- "$@") && \
       eval set -- "${getopt_out}" || bad_usage
while [ $# -ne 0 ]; do
       cur=${1}; next=${2};
       case "$cur" in
               --help) usage ; exit 0;;
               --init) install_prerequisites ; exit 0;;
               --) shift; break;;
       esac
       shift;
done

[ $# -gt 0 ] && bad_usage "too many arguments"

# keep repository up to date
git pull
git submodule init
git submodule update

# run puppet without irritating deprecation warnings
puppet apply $PUPPET_ENV puppet/manifests/site.pp $@ | grep -v 'warning:.*is deprecated'
