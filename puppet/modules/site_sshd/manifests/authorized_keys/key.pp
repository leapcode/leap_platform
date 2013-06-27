define site_sshd::authorized_keys::key ($key, $type) {
  ssh_authorized_key {
    $name:
      type  => $type,
      user  => 'root',
      key   => $key
  }
}
