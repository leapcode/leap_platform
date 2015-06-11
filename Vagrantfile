Vagrant.configure("2") do |config|
  config.vm.define :node1 do |config|

    # Please verify the sha512 sum of the downloaded box before importing it into vagrant !
    # see https://leap.se/en/docs/platform/details/development#Verify.vagrantbox.download
    # for details

    config.vm.box = "leap-wheezy"
    config.vm.box_url = "https://downloads.leap.se/platform/vagrant/virtualbox/leap-wheezy.box"
    #config.vm.network :private_network, ip: "10.5.5.102"
    config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.name = "node1"
    end

    config.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "./vagrant"
      puppet.module_path = "./puppet/modules" 
      puppet.manifest_file = "install-platform.pp"
      puppet.options = "--verbose"
    end
    config.vm.provision "shell", path: "vagrant/configure-leap.sh"

    config.ssh.username = "vagrant"

  end
end
