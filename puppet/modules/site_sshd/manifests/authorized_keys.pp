define site_sshd::authorized_keys ($keys, $ensure = 'present', $home = '') {
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
