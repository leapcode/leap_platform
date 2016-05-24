# htpasswd_file: wether to deploy a passwd for this vhost or not
#   - absent: ignore (default)
#   - nodeploy: htpasswd file isn't deployed by this mechanism
#   - else: try to deploy the file
#
# htpasswd_path: where to deploy the passwd file
#   - absent: standardpath (default)
#   - else: path to deploy
#
# ssl_mode: wether this vhost supports ssl or not
#   - false: don't enable ssl for this vhost (default)
#   - true: enable ssl for this vhost
#   - force: enable ssl and redirect non-ssl to ssl
#   - only: enable ssl only
#
# run_mode: controls in which mode the vhost should be run, there are different setups
#           possible:
#   - normal: (*default*) run vhost with the current active worker (default: prefork) don't
#             setup anything special
#   - itk: run vhost with the mpm_itk module (Incompatibility: cannot be used in combination
#          with 'proxy-itk' & 'static-itk' mode)
#   - proxy-itk: run vhost with a dual prefork/itk setup, where prefork just proxies all the
#                requests for the itk setup, that listens only on the loobpack device.
#                (Incompatibility: cannot be used in combination with the itk setup.)
#   - static-itk: run vhost with a dual prefork/itk setup, where prefork serves all the static
#                 content and proxies the dynamic calls to the itk setup, that listens only on
#                 the loobpack device (Incompatibility: cannot be used in combination with
#                 'itk' mode)
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
#
#
# mod_security: Whether we use mod_security or not
#               (will include mod_security module)
#    - false: (*default*) don't activate mod_security
#    - true: activate mod_security
#
define apache::vhost::file(
    $ensure             = present,
    $configuration      = {},
    $vhost_source       = 'absent',
    $vhost_destination  = 'absent',
    $content            = 'absent',
    $do_includes        = false,
    $run_mode           = 'normal',
    $logmode            = 'default',
    $ssl_mode           = false,
    $mod_security       = false,
    $htpasswd_file      = 'absent',
    $htpasswd_path      = 'absent',
    $use_mod_macro      = false
){
    $vhosts_dir = $::operatingsystem ? {
        centos  => "${apache::centos::config_dir}/vhosts.d",
        gentoo  => "${apache::gentoo::config_dir}/vhosts.d",
        debian  => "${apache::debian::config_dir}/sites-enabled",
        ubuntu  => "${apache::ubuntu::config_dir}/sites-enabled",
        openbsd => "${apache::openbsd::config_dir}/vhosts.d",
        default => '/etc/apache2/vhosts.d',
    }
    $real_vhost_destination = $vhost_destination ? {
        'absent'  => "${vhosts_dir}/${name}.conf",
        default   => $vhost_destination,
    }
    file{"${name}.conf":
        ensure  => $ensure,
        path    => $real_vhost_destination,
        require => File[vhosts_dir],
        notify  => Service[apache],
        owner   => root,
        group   => 0,
        mode    => '0644';
    }
    if $ensure != 'absent' {
      if $do_includes {
        include ::apache::includes
      }
      if $use_mod_macro {
        include ::apache::mod_macro
      }
      case $logmode {
        'semianonym','anonym': { include apache::noiplog }
      }
      case $run_mode {
        'itk': {
          include ::apache::itk::lock
          if $mod_security { include mod_security::itk }
        }
        'proxy-itk','static-itk': {
          include ::apache::itk_plus::lock
          if $mod_security { include mod_security::itk_plus }
        }
        default: {
          if $mod_security { include mod_security }
        }
      }

      case $content {
        'absent': {
            $real_vhost_source = $vhost_source ? {
                'absent'  => [
                    "puppet:///modules/site_apache/vhosts.d/${::fqdn}/${name}.conf",
                    "puppet:///modules/site_apache/vhosts.d/${apache::cluster_node}/${name}.conf",
                    "puppet:///modules/site_apache/vhosts.d/${::operatingsystem}.${::operatingsystemmajrelease}/${name}.conf",
                    "puppet:///modules/site_apache/vhosts.d/${::operatingsystem}/${name}.conf",
                    "puppet:///modules/site_apache/vhosts.d/${name}.conf",
                    "puppet:///modules/apache/vhosts.d/${::operatingsystem}.${::operatingsystemmajrelease}/${name}.conf",
                    "puppet:///modules/apache/vhosts.d/${::operatingsystem}/${name}.conf",
                    "puppet:///modules/apache/vhosts.d/${name}.conf"
                ],
                default => "puppet:///${vhost_source}",
            }
            File["${name}.conf"]{
                source => $real_vhost_source,
            }
        }
        default: {
            File["${name}.conf"]{
                content => $content,
            }
        }
      }
    }
    case $htpasswd_file {
        'absent','nodeploy': { info("don't deploy a htpasswd file for ${name}") }
        default: {
            if $htpasswd_path == 'absent' {
                $real_htpasswd_path = "/var/www/htpasswds/${name}"
            } else {
                $real_htpasswd_path = $htpasswd_path
            }
            file{$real_htpasswd_path:
                ensure => $ensure,
            }
            if ($ensure!='absent') {
              File[$real_htpasswd_path]{
                source  => [ "puppet:///modules/site_apache/htpasswds/${::fqdn}/${name}",
                            "puppet:///modules/site_apache/htpasswds/${apache::cluster_node}/${name}",
                            "puppet:///modules/site_apache/htpasswds/${name}" ],
                owner   => root,
                group   => 0,
                mode    => '0644',
              }
            }
        }
    }
}

