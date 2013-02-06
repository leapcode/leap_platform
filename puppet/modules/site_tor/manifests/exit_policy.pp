class site_tor::exit_policy {
  # exaple policy to allow ssh
  tor::daemon::exit_policy { 'ssh_exit_policy':
    accept => '*:22',
    reject => '*:*';
  }
}

