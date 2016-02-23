# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |box|
  # Please verify the sha512 sum of the downloaded box before importing it into vagrant !
  # see https://leap.se/en/docs/platform/details/development#Verify.vagrantbox.download
  # for details


  box.vm.define :"jessie", primary: true do |config|

    config.vm.box = "LEAP/jessie"
    config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.name   = "jessie"
      v.memory = 1536
    end

    config.vm.provider "libvirt" do |v|
      v.memory = 1536
    end

    config.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "./vagrant"
      puppet.module_path = "./puppet/modules"
      puppet.manifest_file = "install-platform.pp"
      puppet.options = "--verbose"
      puppet.hiera_config_path = "hiera.yaml"
    end
    config.vm.provision "shell", path: "vagrant/configure-leap.sh"
    config.ssh.username = "vagrant"

    # forward leap_web ports
    config.vm.network "forwarded_port", guest: 443, host:4443
    # forward pixelated ports
    config.vm.network "forwarded_port", guest: 8080,  host:8080
  end

end
