#!/bin/bash

set -euxo pipefail

echo -e "deb http://deb.debian.org/debian/ jessie main \ndeb http://security.debian.org/ jessie/updates main" > /etc/apt/sources.list
apt-get update
apt-get install -y --no-install-recommends puppet
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/default/locale
echo 'LC_ALL=en_US.UTF-8' >> /etc/environment
locale-gen
update-locale
