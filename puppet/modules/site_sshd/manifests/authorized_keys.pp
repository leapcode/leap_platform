# We want to purge unmanaged keys from the authorized_keys file so that only
# keys added in the provider are valid. Any manually added keys will be
# overridden.
#
# In order to do this, we have to use a custom define to deploy the
# authorized_keys file because puppet's internal resource doesn't allow
# purging before populating this file.
#
# See the following for more information:
# https://tickets.puppetlabs.com/browse/PUP-1174
# https://leap.se/code/issues/2990
# https://leap.se/code/issues/3010
#
define site_sshd::authorized_keys ($keys, $ensure = 'present', $home = '') {
  # This line allows default homedir based on $title variable.
  # If $home is empty, the default is used.
  $homedir = $home ? {'' => "/home/${title}", default => $home}
  $owner   = $ensure ? {'present' => $title, default => undef }
  $group   = $ensure ? {'present' => $title, default => undef }
  file {
    "${homedir}/.ssh":
      ensure  => 'directory',
      owner   => $title,
      group   => $title,
      mode    => '0700';
    "${homedir}/.ssh/authorized_keys":
      ensure  => $ensure,
      owner   => $owner,
      group   => $group,
      mode    => '0600',
      require => File["${homedir}/.ssh"],
      content => template('site_sshd/authorized_keys.erb');
  }
}
