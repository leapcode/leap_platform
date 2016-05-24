# manage a snippet based tor installation
class tor::daemon (
  $ensure_version           = 'installed',
  $use_munin                = false,
  $data_dir                 = '/var/lib/tor',
  $config_file              = '/etc/tor/torrc',
  $use_bridges              = 0,
  $automap_hosts_on_resolve = 0,
  $log_rules                = [ 'notice file /var/log/tor/notices.log' ],
  $safe_logging             = 1,
) {

  class{'tor':
    ensure_version => $ensure_version,
  }

  include tor::daemon::base

  if $use_munin {
    include tor::munin
  }
}
