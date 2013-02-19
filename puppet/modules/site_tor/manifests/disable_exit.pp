class site_tor::disable_exit {
  tor::daemon::exit_policy {
    'no_exit_at_all':
      reject => '*:*';
  }
}

