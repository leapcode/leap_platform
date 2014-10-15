# encoding: utf-8
#
# These are variables defined by this leap_platform and used by leap_cli.
#

Leap::Platform.define do
  self.version = "0.5.5"
  self.compatible_cli = "1.5.5".."1.5.7"

  #
  # the facter facts that should be gathered
  #
  self.facts = ["ec2_local_ipv4", "ec2_public_ipv4"]

  #
  # the named paths for this platform
  #
  self.paths = {
    # directories
    :hiera_dir        => 'hiera',
    :files_dir        => 'files',
    :nodes_dir        => 'nodes',
    :services_dir     => 'services',
    :tags_dir         => 'tags',
    :node_files_dir   => 'files/nodes/#{arg}',

    # input config files
    :common_config    => 'common.json',
    :provider_config  => 'provider.json',
    :secrets_config   => 'secrets.json',
    :node_config      => 'nodes/#{arg}.json',
    :service_config   => 'services/#{arg}.json',
    :tag_config       => 'tags/#{arg}.json',

    # input config files, environmentally scoped
    :provider_env_config  => 'provider.#{arg}.json',
    :service_env_config   => 'services/#{arg[0]}.#{arg[1]}.json',
    :tag_env_config       => 'tags/#{arg[0]}.#{arg[1]}.json',

    # input templates
    :provider_json_template        => 'files/service-definitions/provider.json.erb',
    :eip_service_json_template     => 'files/service-definitions/#{arg}/eip-service.json.erb',
    :soledad_service_json_template => 'files/service-definitions/#{arg}/soledad-service.json.erb',
    :smtp_service_json_template    => 'files/service-definitions/#{arg}/smtp-service.json.erb',

    # output files
    :facts            => 'facts.json',
    :user_ssh         => 'users/#{arg}/#{arg}_ssh.pub',
    :user_pgp         => 'users/#{arg}/#{arg}_pgp.pub',
    :known_hosts      => 'files/ssh/known_hosts',
    :authorized_keys  => 'files/ssh/authorized_keys',
    :monitor_pub_key  => 'files/ssh/monitor_ssh.pub',
    :monitor_priv_key => 'files/ssh/monitor_ssh',
    :ca_key           => 'files/ca/ca.key',
    :ca_cert          => 'files/ca/ca.crt',
    :client_ca_key    => 'files/ca/client_ca.key',
    :client_ca_cert   => 'files/ca/client_ca.crt',
    :dh_params        => 'files/ca/dh.pem',
    :commercial_key   => 'files/cert/#{arg}.key',
    :commercial_csr   => 'files/cert/#{arg}.csr',
    :commercial_cert  => 'files/cert/#{arg}.crt',
    :commercial_ca_cert  => 'files/cert/commercial_ca.crt',
    :vagrantfile      => 'test/Vagrantfile',

    # node output files
    :hiera            => 'hiera/#{arg}.yaml',
    :node_ssh_pub_key => 'files/nodes/#{arg}/#{arg}_ssh.pub',
    :node_x509_key    => 'files/nodes/#{arg}/#{arg}.key',
    :node_x509_cert   => 'files/nodes/#{arg}/#{arg}.crt',

    # testing files
    :test_client_key     => 'test/cert/client.key',
    :test_client_cert    => 'test/cert/client.crt',
    :test_openvpn_config => 'test/openvpn/#{arg}.ovpn',
    :test_client_openvpn_template => 'test/openvpn/client.ovpn.erb'
  }

  #
  # the files that need to get renamed when a node is renamed
  #
  self.node_files = [
    :node_config, :hiera, :node_x509_cert, :node_x509_key, :node_ssh_pub_key
  ]

  self.monitor_username = 'monitor'

  self.reserved_usernames = ['monitor']
end

