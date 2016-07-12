# configure check_mk server
class check_mk (
  $filestore                 = undef,
  $host_groups               = undef,
  $package                   = 'omd-0.56',
  $site                      = 'monitoring',
  $workspace                 = '/root/check_mk',
  $omd_service_name          = 'omd',
  $http_service_name         = 'httpd',
  $xinitd_service_name       = 'xinetd',
  $omdadmin_htpasswd         = undef,
  $use_ssh                   = false,
  $shelluser                 = 'monitoring',
  $shellgroup                = 'monitoring',
  $use_storedconfigs         = true,
  $inventory_only_on_changes = true) {

  class { 'check_mk::install':
    filestore => $filestore,
    package   => $package,
    site      => $site,
    workspace => $workspace,
  }
  class { 'check_mk::config':
    host_groups               => $host_groups,
    site                      => $site,
    use_storedconfigs         => $use_storedconfigs,
    inventory_only_on_changes => $inventory_only_on_changes,
    require                   => Class['check_mk::install'],
  }
  class { 'check_mk::service':
    require   => Class['check_mk::config'],
  }
  if $omdadmin_htpasswd {
    class { 'check_mk::htpasswd':
      password => $omdadmin_htpasswd
    }
  }

  if ( $use_ssh == true ) {
    class { 'check_mk::server::configure_ssh': }
  }

}
