#!/bin/bash
#
# adds pixelated-server to the node

. /vagrant/vagrant/vagrant.config

cd "$PROVIDERDIR"

if ! [ -d files/puppet/modules/pixelated ]; then
  git clone https://github.com/pixelated/puppet-pixelated.git files/puppet/modules/pixelated
fi

echo '{}' > services/pixelated.json
[ -d files/puppet/modules/custom/manifests ] || mkdir -p files/puppet/modules/custom/manifests
echo 'class custom { include ::pixelated}' > files/puppet/modules/custom/manifests/init.pp

$LEAP $OPTS -v 2 deploy

echo '==============================================='
echo 'testing the platform'
echo '==============================================='

$LEAP $OPTS -v 2 test --continue


echo -e '\n===========================================================================================================\n\n'
echo -e 'You are now ready to use your vagrant Pixelated provider.\n'

echo -e 'The LEAP webapp is available at https://localhost:4443. Use it to register an account before using the Pixelated User Agent.\n'
echo -e 'The Pixelated User Agent is available at https://localhost:8080\n'

echo -e 'Please add an exception for both sites in your browser dialog to allow the self-signed certificate.\n'
