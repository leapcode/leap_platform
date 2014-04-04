define site_sshd::authorized_keys ($keys, $ensure = 'present', $home = '') {
  # We use a custom define here to deploy the authorized_keys file
  # cause puppet doesn't allow purgin before populating this file
  # (see https://tickets.puppetlabs.com/browse/PUP-1174)
  # This line allows default homedir based on $title variable.
  # If $home is empty, the default is used.
  $homedir = $home ? {'' => "/home/${title}", default => $home}
  file {
    "${homedir}/.ssh":
      ensure  => 'directory',
      owner   => $title,
      group   => $title,
      mode    => '0700';
    "${homedir}/.ssh/authorized_keys":
      ensure  => $ensure,
      owner   => $ensure ? {'present' => $title, default => undef },
      group   => $ensure ? {'present' => $title, default => undef },
      mode    => '0600',
      require => File["${homedir}/.ssh"],
      content => template('site_sshd/authorized_keys.erb');
  }
}
