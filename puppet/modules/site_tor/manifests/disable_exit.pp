# ensure that the tor relay is not configured as an exit node
class site_tor::disable_exit {
  tor::daemon::exit_policy {
    'no_exit_at_all':
      reject => [ '*:*' ];
  }
# In a future version of Tor, ExitRelay 0 may become the default when no ExitPolicy is given.
  tor::daemon::snippet {
    'disable_exit':
      content => 'ExitRelay 0';
  }
}

