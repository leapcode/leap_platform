# check_gpg from
# https://github.com/lelutin/nagios-plugins/blob/master/check_gpg
class nagios::plugins::gpg {
  require ::gpg
  nagios::plugin{'check_gpg':
    source => 'nagios/plugins/check_gpg',
  }

  $gpg_home = '/var/local/nagios_gpg_homedir'
  file{
    $gpg_home:
      ensure  => 'directory',
      owner   => nagios,
      group   => nagios,
      mode    => '0600',
      require => Nagios::Plugin['check_gpg'];
    "${gpg_home}/sks-keyservers.netCA.pem":
      source  => 'puppet:///modules/nagios/plugin_data/sks-keyservers.netCA.pem',
      owner   => nagios,
      group   => 0,
      mode    => '0400',
      before  => Nagios_command['check_gpg'];
  }
  nagios_command {
    'check_gpg':
      command_line => "\$USER1\$/check_gpg --gnupg-homedir ${gpg_home} -w \$ARG1\$ \$ARG2\$",
      require      => Nagios::Plugin['check_gpg'],
  }
}

