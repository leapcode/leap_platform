#!/bin/bash
#
# adds pixelated-server to the node

. /vagrant/vagrant/vagrant.config

cd "$PROVIDERDIR"

if ! git submodule status files/puppet/modules/pixelated > /dev/null 2>&1; then
  git submodule add https://github.com/pixelated/puppet-pixelated.git files/puppet/modules/pixelated
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

echo -e 'The LEAP webapp is available at https://localhost:4443. Use it to register an account before using the Pixelated Useragent.\n'
echo -e 'The Pixelated Useragent is available at https://localhost:8080\n'

echo -e 'Please add an exception for both sites in your browser dialog to allow the self-signed certificate.\n'
