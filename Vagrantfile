# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # shared config for all boxes

  # Please verify the sha512 sum of the downloaded box before importing it into vagrant !
  # see https://leap.se/en/docs/platform/details/development#Verify.vagrantbox.download
  # for details
  config.vm.box = "LEAP/jessie"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.name   = "jessie"
    v.memory = 1536
  end

  config.vm.provider "libvirt" do |v|
    v.memory = 1536
  end

  # Fix annoying 'stdin: is not a tty' warning
  # see http://foo-o-rama.com/vagrant--stdin-is-not-a-tty--fix.html
  config.vm.provision "shell" do |s|
    s.privileged = false
    s.inline     = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path    = "./vagrant"
    puppet.module_path       = "./puppet/modules"
    puppet.manifest_file     = "install-platform.pp"
    puppet.options           = "--verbose"
    puppet.hiera_config_path = "hiera.yaml"
  end
  config.vm.provision "shell", path: "vagrant/configure-leap.sh"

  config.ssh.username = "vagrant"

  # forward leap_web ports
  config.vm.network "forwarded_port", guest: 443, host:4443
  # forward pixelated ports
  config.vm.network "forwarded_port", guest: 8080,  host:8080

  config.vm.define :"leap_platform", primary: true do |leap_vagrant|
  end

  config.vm.define :"pixelated", autostart: false do |pixelated_vagrant|
    pixelated_vagrant.vm.provision "shell", path: "vagrant/add-pixelated.sh"
  end

end
