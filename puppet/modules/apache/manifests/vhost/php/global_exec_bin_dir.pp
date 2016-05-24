# manage global exec_bin_dir
class apache::vhost::php::global_exec_bin_dir {
  file{'/var/www/php_safe_exec_bins':
    ensure  => directory,
    owner   => root,
    group   => apache,
    mode    => '0640';
  }
}
