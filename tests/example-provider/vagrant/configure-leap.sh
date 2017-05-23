#!/bin/sh

# Exit on failure
set -e

# shellcheck disable=SC1091
. /vagrant/vagrant/vagrant.config

echo '==============================================='
echo "Configuring LEAP in ${PROVIDERDIR}"
echo '==============================================='

# purge $PROVIDERDIR so this script can be run multiple times
[ -e "$PROVIDERDIR" ] && rm -rf "$PROVIDERDIR"

mkdir -p "$PROVIDERDIR"
chown "${USER}:${USER}" "${PROVIDERDIR}"
cd "$PROVIDERDIR" || exit

$LEAP new --contacts "${contacts:?}" --domain "${provider_domain:?}" --name "${provider_name:?}" --platform="$PLATFORMDIR" .
printf '\n@log = "./deploy.log"' >> Leapfile

if [ ! -e "/home/${USER}/.ssh/id_rsa" ]; then
  $SUDO ssh-keygen -f "/home/${USER}/.ssh/id_rsa" -P ''
  [ -d /root/.ssh ] || mkdir /root/.ssh
  cat "/home/${USER}/.ssh/id_rsa.pub" >> /root/.ssh/authorized_keys
fi

$SUDO mkdir -p "${PROVIDERDIR}/files/nodes/${NODE}"
sh -c "cat /etc/ssh/ssh_host_rsa_key.pub | cut -d' ' -f1,2 >> $PROVIDERDIR/files/nodes/$NODE/${NODE}_ssh.pub"
chown "${USER}:${USER}" "${PROVIDERDIR}/files/nodes/${NODE}/${NODE}_ssh.pub"

$LEAP add-user --self
$LEAP cert ca
$LEAP cert csr

# Try to see if there's a private IP for eth1
# Otherwise take eth0
# (virtualbox and libvirt backends behave differenently setting up
# direct accessible private networks.
# see https://www.vagrantup.com/docs/networking/private_network.html
IP="$(facter ipaddress_eth1)"
[ "$IP" = '' ] && IP="$(facter ipaddress_eth0)"
$LEAP node add "$NODE" ip_address:"${IP}" couch.mode:plain  services:"${services:?}" tags:production

echo '{ "webapp": { "admins": ["testadmin"] } }' > services/webapp.json

$LEAP compile

$LEAP node init "$NODE"
if [ $? -eq 1 ]; then
  echo 'node init failed'
  exit 1
fi

# couchrest gem does currently not install on jessie
# https://leap.se/code/issues/7754
# workaround is to install rake as gem
gem install rake

$LEAP -v 2 deploy

# Vagrant: leap_mx fails to start on jessie
# https://leap.se/code/issues/7755
# Workaround: we stop and start leap-mx after deploy and
# before testing

service leap-mx stop
service leap-mx start



echo '==============================================='
echo 'testing the platform'
echo '==============================================='

$LEAP -v 2 test --continue

echo '==============================================='
echo 'setting node to demo-mode'
echo '==============================================='
postconf -e default_transport='error: in demo mode'

# add users: testadmin and testuser with passwords "hallo123"
curl -s -k https://localhost/1/users.json -d "user%5Blogin%5D=testuser&user%5Bpassword_salt%5D=7d4880237a038e0e&user%5Bpassword_verifier%5D=b98dc393afcd16e5a40fb57ce9cddfa6a978b84be326196627c111d426cada898cdaf3a6427e98b27daf4b0ed61d278bc856515aeceb2312e50c8f816659fcaa4460d839a1e2d7ffb867d32ac869962061368141c7571a53443d58dc84ca1fca34776894414c1090a93e296db6cef12c2cc3f7a991b05d49728ed358fd868286"
curl -s -k https://localhost/1/users.json -d "user%5Blogin%5D=testadmin&user%5Bpassword_salt%5D=ece1c457014d8282&user%5Bpassword_verifier%5D=9654d93ab409edf4ff1543d07e08f321107c3fd00de05c646c637866a94f28b3eb263ea9129dacebb7291b3374cc6f0bf88eb3d231eb3a76eed330a0e8fd2a5c477ed2693694efc1cc23ae83c2ae351a21139701983dd595b6c3225a1bebd2a4e6122f83df87606f1a41152d9890e5a11ac3749b3bfcf4407fc83ef60b4ced68"

printf '\n===========================================================================================================\n\n'
printf 'You are now ready to use your local LEAP provider.\n'
echo 'If you want to use the *Bitmask client* with your provider, please update your /etc/hosts with following dns overrides:'

$LEAP list --print ip_address,domain.full,dns.aliases | sed 's/^.*  //' | sed 's/, null//g' | tr -d '\]\[",'

echo 'Please see https://leap.se/en/docs/platform/tutorials/vagrant#use-the-bitmask-client-to-do-an-initial-soledad-sync for more details how to use and test your LEAP provider.'
printf "\nIf you don't want to use the Bitmask client, please ignore the above instructions.\n"
printf 'The LEAP webapp is now available at https://localhost:4443\n'
printf 'Please add an exception in your browser dialog to allow the self-signed certificate.\n'
