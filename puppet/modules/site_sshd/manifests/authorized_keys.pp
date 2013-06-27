class site_sshd::authorized_keys {
  tag 'leap_authorized_keys'

  create_resources(site_sshd::authorized_keys::key, $site_sshd::ssh_authorized_keys)

}
