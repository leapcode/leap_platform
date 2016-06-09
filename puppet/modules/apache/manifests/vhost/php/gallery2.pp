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
#
# run_uid: the uid the vhost should run as with the itk module
# run_gid: the gid the vhost should run as with the itk module
#
# mod_security: Whether we use mod_security or not (will include mod_security module)
#    - false: (*defaul*) don't activate mod_security
#    - true: activate mod_security
#
# php_safe_mode_exec_bins: An array of local binaries which should be linked in the
#                          safe_mode_exec_bin for this hosting
#                          *default*: None
# php_default_charset: default charset header for php.
#                      *default*: absent, which will set the same as default_charset
#                                 of apache
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
define apache::vhost::php::gallery2(
  $ensure                           = present,
  $configuration                    = {},
  $domain                           = 'absent',
  $domainalias                      = 'absent',
  $server_admin                     = 'absent',
  $logmode                          = 'default',
  $path                             = 'absent',
  $owner                            = root,
  $group                            = apache,
  $documentroot_owner               = apache,
  $documentroot_group               = 0,
  $documentroot_mode                = 0640,
  $run_mode                         = 'normal',
  $run_uid                          = 'absent',
  $run_gid                          = 'absent',
  $allow_override                   = 'None',
  $php_settings                     = {},
  $php_options                      = {},
  $do_includes                      = false,
  $options                          = 'absent',
  $additional_options               = 'absent',
  $default_charset                  = 'absent',
  $mod_security                     = false,
  $mod_security_relevantonly        = true,
  $mod_security_rules_to_disable    = [],
  $mod_security_additional_options  = 'absent',
  $ssl_mode                         = false,
  $vhost_mode                       = 'template',
  $template_partial                 = 'apache/vhosts/php_gallery2/partial.erb',
  $vhost_source                     = 'absent',
  $vhost_destination                = 'absent',
  $htpasswd_file                    = 'absent',
  $htpasswd_path                    = 'absent',
  $manage_config                    = true,
  $config_webwriteable              = false,
  $manage_directories               = true,
){
  $documentroot = $path ? {
    'absent' => $::operatingsystem ? {
      openbsd => "/var/www/htdocs/${name}/www",
      default => "/var/www/vhosts/${name}/www"
    },
    default => "${path}/www"
  }
  $upload_dir = "/var/www/vhosts/${name}/data/upload"
  $gdata_dir = "/var/www/vhosts/${name}/data/gdata"
  if $ensure != 'absent' {
    file{
      $gdata_dir:
        ensure  => 'directory',
        owner   => $documentroot_owner,
        group   => $documentroot_group,
        mode    => '0660';
      $upload_dir:
        ensure  => 'directory',
        owner   => $documentroot_owner,
        group   => $documentroot_group,
        mode    => '0660';
    }
  }

  $gallery_php_settings = {
    safe_mode        => 'Off',
    output_buffering => 'Off',
  }
  $real_php_settings = merge($gallery_php_settings,$php_settings)

  # create vhost configuration file
  ::apache::vhost::php::webapp{$name:
    ensure                          => $ensure,
    configuration                   => $configuration,
    domain                          => $domain,
    domainalias                     => $domainalias,
    server_admin                    => $server_admin,
    logmode                         => $logmode,
    path                            => $path,
    owner                           => $owner,
    group                           => $group,
    documentroot_owner              => $documentroot_owner,
    documentroot_group              => $documentroot_group,
    documentroot_mode               => $documentroot_mode,
    run_mode                        => $run_mode,
    run_uid                         => $run_uid,
    run_gid                         => $run_gid,
    allow_override                  => $allow_override,
    php_settings                    => $real_php_settings,
    php_options                     => $php_options,
    do_includes                     => $do_includes,
    options                         => $options,
    additional_options              => $additional_options,
    default_charset                 => $default_charset,
    mod_security                    => $mod_security,
    mod_security_relevantonly       => $mod_security_relevantonly,
    mod_security_rules_to_disable   => $mod_security_rules_to_disable,
    mod_security_additional_options => $mod_security_additional_options,
    ssl_mode                        => $ssl_mode,
    vhost_mode                      => $vhost_mode,
    template_partial                => $template_partial,
    vhost_source                    => $vhost_source,
    vhost_destination               => $vhost_destination,
    htpasswd_file                   => $htpasswd_file,
    htpasswd_path                   => $htpasswd_path,
    manage_directories              => $manage_directories,
    manage_config                   => $manage_config,
    config_file                     => 'config.php',
  }
}

