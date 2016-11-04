define backupninja::generate_sshkey(
  $ssh_key_basepath = '/etc/puppet/modules/keys/files/backupkeys',
){

  # generate backupninja ssh keypair
  $ssh_key_name = "backup_${::hostname}_id_rsa"
  $ssh_keys = ssh_keygen("${ssh_key_basepath}/${ssh_key_name}")
  $public = split($ssh_keys[1],' ')
  $public_type = $public[0]
  $public_key = $public[1]

  file { '/root/.ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0600';
  }

  # install ssh keypair on client
  file { "/root/.ssh/$ssh_key_name":
    content => $ssh_keys[0],
    owner   => root,
    group   => 0,
    mode    => '0600';
  }

  file { "/root/.ssh/$ssh_key_name.pub":
    content => $public_key,
    owner   => root,
    group   => 0,
    mode    => '0666';
  }
}
