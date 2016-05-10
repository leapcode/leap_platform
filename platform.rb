# encoding: utf-8
#
# These are variables defined by this leap_platform and used by leap_cli.
#

Leap::Platform.define do
  self.version = "0.8"
  self.compatible_cli = "1.8".."1.99"

  #
  # the facter facts that should be gathered
  #
  self.facts = ["ec2_local_ipv4", "ec2_public_ipv4"]

  #
  # absolute paths on the destination server
  #
  self.hiera_dir  = '/etc/leap' if self.respond_to?(:hiera_dir)
  self.hiera_path = '/etc/leap/hiera.yaml'
  self.leap_dir   = '/srv/leap'
  self.files_dir  = '/srv/leap/files'
  self.init_path  = '/srv/leap/initialized'

  #
  # the named paths for this platform
  # (relative to the provider directory)
  #
  self.paths = {
    # directories
    :hiera_dir        => 'hiera',
    :files_dir        => 'files',
    :nodes_dir        => 'nodes',
    :services_dir     => 'services',
    :templates_dir    => 'templates',
    :tags_dir         => 'tags',
    :node_files_dir   => 'files/nodes/#{arg}',

    # input config files
    :common_config    => 'common.json',
    :provider_config  => 'provider.json',
    :service_config   => 'services/#{arg}.json',
    :tag_config       => 'tags/#{arg}.json',
    :template_config  => 'templates/#{arg}.json',
    :secrets_config   => 'secrets.json',
    :node_config      => 'nodes/#{arg}.json',

    # input config files, environmentally scoped
    :common_env_config    => 'commmon.#{arg}.json',
    :provider_env_config  => 'provider.#{arg}.json',
    :service_env_config   => 'services/#{arg[0]}.#{arg[1]}.json',
    :tag_env_config       => 'tags/#{arg[0]}.#{arg[1]}.json',

    # input templates
    :provider_json_template        => 'files/service-definitions/provider.json.erb',
    :eip_service_json_template     => 'files/service-definitions/#{arg}/eip-service.json.erb',
    :soledad_service_json_template => 'files/service-definitions/#{arg}/soledad-service.json.erb',
    :smtp_service_json_template    => 'files/service-definitions/#{arg}/smtp-service.json.erb',

    # custom files
    :custom_puppet_dir => 'files/puppet',
    :custom_puppet_modules_dir => 'files/puppet/modules',
    :custom_puppet_manifests_dir => 'files/puppet/manifests',
    :custom_tests => 'files/tests',
    :custom_bin => 'files/bin',

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
    :dkim_priv_key    => 'files/mx/dkim.key',
    :dkim_pub_key     => 'files/mx/dkim.pub',

    :commercial_ca_cert       => 'files/cert/commercial_ca.crt',
    :vagrantfile              => 'test/Vagrantfile',
    :static_web_provider_json => 'files/web/bootstrap/#{arg}/provider.json',
    :static_web_htaccess      => 'files/web/bootstrap/#{arg}/htaccess',
    :static_web_readme        => 'files/web/bootstrap/README',

    # node output files
    :hiera             => 'hiera/#{arg}.yaml',
    :node_ssh_pub_key  => 'files/nodes/#{arg}/#{arg}_ssh.pub',
    :node_x509_key     => 'files/nodes/#{arg}/#{arg}.key',
    :node_x509_cert    => 'files/nodes/#{arg}/#{arg}.crt',
    :node_tor_priv_key => 'files/nodes/#{arg}/tor.key',
    :node_tor_pub_key  => 'files/nodes/#{arg}/tor.pub',

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

  self.reserved_usernames = ['monitor', 'root']

  self.default_puppet_tags = ['leap_base','leap_service']
end

