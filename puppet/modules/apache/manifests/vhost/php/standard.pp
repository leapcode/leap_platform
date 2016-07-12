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
#    - false: don't activate mod_security
#    - true: (*default*) activate mod_security
#
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
define apache::vhost::php::standard(
  $ensure                           = present,
  $configuration                    = {},
  $domain                           = 'absent',
  $domainalias                      = 'absent',
  $server_admin                     = 'absent',
  $logmode                          = 'default',
  $logpath                          = 'absent',
  $logprefix                        = '',
  $path                             = 'absent',
  $manage_webdir                    = true,
  $path_is_webdir                   = false,
  $manage_docroot                   = true,
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
  $php_installation                 = 'system',
  $do_includes                      = false,
  $options                          = 'absent',
  $additional_options               = 'absent',
  $default_charset                  = 'absent',
  $use_mod_macro                    = false,
  $mod_security                     = true,
  $mod_security_relevantonly        = true,
  $mod_security_rules_to_disable    = [],
  $mod_security_additional_options  = 'absent',
  $ssl_mode                         = false,
  $vhost_mode                       = 'template',
  $template_partial                 = 'apache/vhosts/php/partial.erb',
  $vhost_source                     = 'absent',
  $vhost_destination                = 'absent',
  $htpasswd_file                    = 'absent',
  $htpasswd_path                    = 'absent',
){

  if $manage_webdir {
    # create webdir
    ::apache::vhost::webdir{$name:
      ensure              => $ensure,
      path                => $path,
      owner               => $owner,
      group               => $group,
      run_mode            => $run_mode,
      manage_docroot      => $manage_docroot,
      documentroot_owner  => $documentroot_owner,
      documentroot_group  => $documentroot_group,
      documentroot_mode   => $documentroot_mode,
    }
  }

  $real_path = $path ? {
    'absent' => $::operatingsystem ? {
      openbsd => "/var/www/htdocs/${name}",
      default => "/var/www/vhosts/${name}"
    },
    default   => $path
  }

  if $path_is_webdir {
    $documentroot = $real_path
  } else {
    $documentroot = "${real_path}/www"
  }
  $logdir = $logpath ? {
    'absent'  => "${real_path}/logs",
    default   => $logpath
  }

  $std_php_options = {
    smarty  => false,
    pear    => false,
  }
  $real_php_options = merge($std_php_options,$php_options)

  if $real_php_options[smarty] {
    include php::extensions::smarty
    $smarty_path = '/usr/share/php/Smarty/:'
  } else {
    $smarty_path = ''
  }

  if $real_php_options[pear] {
    $pear_path = '/usr/share/pear/:'
  } else {
    $pear_path = ''
  }

  if $logmode != 'nologs' {
    $php_error_log = "${logdir}/php_error_log"
  } else {
    $php_error_log = undef
  }

  if ('safe_mode_exec_dir' in $php_settings) {
    $php_safe_mode_exec_dir = $php_settings[safe_mode_exec_dir]
  } else {
    $php_safe_mode_exec_dir =  $path ? {
      'absent' => $::operatingsystem ? {
        openbsd => "/var/www/htdocs/${name}/bin",
        default => "/var/www/vhosts/${name}/bin"
      },
      default   => "${path}/bin"
    }
  }
  file{$php_safe_mode_exec_dir:
    recurse => true,
    force   => true,
    purge   => true,
  }
  if ('safe_mode_exec_bins' in $php_options) {
    $std_php_settings_safe_mode_exec_dir = $php_safe_mode_exec_dir
    $ensure_exec = $ensure ? {
      'present'  => directory,
      default    => 'absent',
    }
    File[$php_safe_mode_exec_dir]{
      ensure => $ensure_exec,
      owner  => $documentroot_owner,
      group  => $documentroot_group,
      mode   => '0750',
    }
    $php_safe_mode_exec_bins_subst = regsubst($php_options[safe_mode_exec_bins],'(.+)',"${name}@\\1")
    apache::vhost::php::safe_mode_bin{
      $php_safe_mode_exec_bins_subst:
        ensure  => $ensure,
        path    => $php_safe_mode_exec_dir;
    }
  } else {
    $std_php_settings_safe_mode_exec_dir = undef
    File[$php_safe_mode_exec_dir]{
      ensure => absent,
    }
  }

  if !('default_charset' in $php_settings) and ($default_charset != 'absent') {
    $std_php_settings_default_charset =  $default_charset ? {
      'On'    => 'iso-8859-1',
      default => $default_charset
    }
  } else {
    $std_php_settings_default_charset = undef
  }

  if ('additional_open_basedir' in $php_options) {
    $the_open_basedir = "${smarty_path}${pear_path}${documentroot}:${real_path}/data:/var/www/upload_tmp_dir/${name}:/var/www/session.save_path/${name}:${php_options[additional_open_basedir]}"
  } else {
    $the_open_basedir = "${smarty_path}${pear_path}${documentroot}:${real_path}/data:/var/www/upload_tmp_dir/${name}:/var/www/session.save_path/${name}"
  }

  if $run_mode == 'fcgid' {
    $safe_mode_gid = $::operatingsystem ? {
      debian  => undef,
      default => $php_installation ? {
        'system'  => 'On',
        default   => undef,
      }
    }
  } else {
    $safe_mode_gid = undef
  }

  $safe_mode = $::operatingsystem ? {
    debian  => undef,
    default => $php_installation ? {
      'system'  => 'On',
      default   => undef,
    }
  }
  $std_php_settings = {
    engine              => 'On',
    upload_tmp_dir      => "/var/www/upload_tmp_dir/${name}",
    'session.save_path' => "/var/www/session.save_path/${name}",
    error_log           => $php_error_log,
    safe_mode           => $safe_mode,
    safe_mode_gid       => $safe_mode_gid,
    safe_mode_exec_dir  => $std_php_settings_safe_mode_exec_dir,
    default_charset     => $std_php_settings_default_charset,
    open_basedir        => $the_open_basedir,
  }

  $real_php_settings = merge($std_php_settings,$php_settings)

  if $ensure != 'absent' {
    case $run_mode {
      'proxy-itk','static-itk': {
        include ::php::itk_plus
      }
      'itk': { include ::php::itk }
      'fcgid': {
        include ::mod_fcgid
        include ::php::mod_fcgid
        include apache::include::mod_fcgid

        mod_fcgid::starter {$name:
          tmp_dir          => $real_php_settings[php_tmp_dir],
          cgi_type         => 'php',
          cgi_type_options => delete($real_php_settings, php_tmp_dir),
          owner            => $run_uid,
          group            => $run_gid,
          notify           => Service['apache'],
        }
        if $php_installation == 'scl54' {
          require php::scl::php54
          Mod_fcgid::Starter[$name]{
            binary          => '/opt/rh/php54/root/usr/bin/php-cgi',
            additional_cmds => 'source /opt/rh/php54/enable',
            rc              => '/opt/rh/php54/root/etc',
          }
        } elsif $php_installation == 'scl55' {
          require php::scl::php55
          Mod_fcgid::Starter[$name]{
            binary          => '/opt/rh/php55/root/usr/bin/php-cgi',
            additional_cmds => 'source /opt/rh/php55/enable',
            rc              => '/opt/rh/php55/root/etc',
          }
        }
      }
      default: { include ::php }
    }
  }

  ::apache::vhost::phpdirs{$name:
    ensure                => $ensure,
    php_upload_tmp_dir    => $real_php_settings[upload_tmp_dir],
    php_session_save_path => $real_php_settings['session.save_path'],
    documentroot_owner    => $documentroot_owner,
    documentroot_group    => $documentroot_group,
    documentroot_mode     => $documentroot_mode,
    run_mode              => $run_mode,
    run_uid               => $run_uid,
  }

  # create vhost configuration file
  ::apache::vhost{$name:
    ensure                          => $ensure,
    configuration                   => $configuration,
    path                            => $path,
    path_is_webdir                  => $path_is_webdir,
    vhost_mode                      => $vhost_mode,
    template_partial                => $template_partial,
    vhost_source                    => $vhost_source,
    vhost_destination               => $vhost_destination,
    domain                          => $domain,
    domainalias                     => $domainalias,
    server_admin                    => $server_admin,
    logmode                         => $logmode,
    logpath                         => $logpath,
    logprefix                       => $logprefix,
    run_mode                        => $run_mode,
    run_uid                         => $run_uid,
    run_gid                         => $run_gid,
    allow_override                  => $allow_override,
    do_includes                     => $do_includes,
    options                         => $options,
    additional_options              => $additional_options,
    default_charset                 => $default_charset,
    php_settings                    => $real_php_settings,
    php_options                     => $real_php_options,
    ssl_mode                        => $ssl_mode,
    htpasswd_file                   => $htpasswd_file,
    htpasswd_path                   => $htpasswd_path,
    mod_security                    => $mod_security,
    mod_security_relevantonly       => $mod_security_relevantonly,
    mod_security_rules_to_disable   => $mod_security_rules_to_disable,
    mod_security_additional_options => $mod_security_additional_options,
    use_mod_macro                   => $use_mod_macro,
    passing_extension               => 'php',
  }
}

