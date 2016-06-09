# Webdav vhost: to manage webdav accessible targets
# run_mode: controls in which mode the vhost should be run, there are different setups
#           possible:
#   - normal: (*default*) run vhost with the current active worker (default: prefork) don't
#             setup anything special
#   - itk: run vhost with the mpm_itk module (Incompatibility: cannot be used in combination
#          with 'proxy-itk' & 'static-itk' mode)
#   - proxy-itk: run vhost with a dual prefork/itk setup, where prefork just proxies all the
#                requests for the itk setup, that listens only on the loobpack device.
#                (Incompatibility: cannot be used in combination with the itk setup.)
#   - static-itk: this mode is not possible and will be rewritten to proxy-itk
#
# run_uid: the uid the vhost should run as with the itk module
# run_gid: the gid the vhost should run as with the itk module
#
# mod_security: Whether we use mod_security or not (will include mod_security module)
#    - false: (*default*) don't activate mod_security
#    - true: activate mod_security
#
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
#
define apache::vhost::webdav(
    $ensure                           = present,
    $configuration                    = {},
    $domain                           = 'absent',
    $domainalias                      = 'absent',
    $server_admin                     = 'absent',
    $path                             = 'absent',
    $owner                            = root,
    $group                            = apache,
    $manage_webdir                    = true,
    $path_is_webdir                   = false,
    $logmode                          = 'default',
    $logpath                          = 'absent',
    $documentroot_owner               = apache,
    $documentroot_group               = 0,
    $documentroot_mode                = 0640,
    $run_mode                         = 'normal',
    $run_uid                          = 'absent',
    $run_gid                          = 'absent',
    $options                          = 'absent',
    $additional_options               = 'absent',
    $default_charset                  = 'absent',
    $mod_security                     = false,
    $mod_security_relevantonly        = true,
    $mod_security_rules_to_disable    = [],
    $mod_security_additional_options  = 'absent',
    $ssl_mode                         = false,
    $vhost_mode                       = 'template',
    $vhost_source                     = 'absent',
    $vhost_destination                = 'absent',
    $htpasswd_file                    = 'absent',
    $htpasswd_path                    = 'absent',
    $ldap_auth                        = false,
    $ldap_user                        = 'any',
    $dav_db_dir                       = 'absent'
){
  ::apache::vhost::davdbdir{$name:
    ensure              => $ensure,
    dav_db_dir          => $dav_db_dir,
    documentroot_owner  => $documentroot_owner,
    documentroot_group  => $documentroot_group,
    documentroot_mode   => $documentroot_mode,
    run_mode            => $run_mode,
    run_uid             => $run_uid,
  }

  if $manage_webdir {
    # create webdir
    ::apache::vhost::webdir{$name:
      ensure              => $ensure,
      path                => $path,
      owner               => $owner,
      group               => $group,
      run_mode            => $run_mode,
      datadir             => false,
      documentroot_owner  => $documentroot_owner,
      documentroot_group  => $documentroot_group,
      documentroot_mode   => $documentroot_mode,
    }
  }

  if $run_mode == 'static-itk' {
    notice('static-itk mode is not possible for webdav vhosts, rewriting it to proxy-itk')
    $real_run_mode = 'proxy-itk'
  } else {
    $real_run_mode = $run_mode
  }

  # create vhost configuration file
  ::apache::vhost{$name:
    ensure                          => $ensure,
    configuration                   => $configuration,
    path                            => $path,
    path_is_webdir                  => $path_is_webdir,
    logpath                         => $logpath,
    logmode                         => $logmode,
    template_partial                => 'apache/vhosts/webdav/partial.erb',
    vhost_mode                      => $vhost_mode,
    vhost_source                    => $vhost_source,
    vhost_destination               => $vhost_destination,
    domain                          => $domain,
    domainalias                     => $domainalias,
    server_admin                    => $server_admin,
    run_mode                        => $real_run_mode,
    run_uid                         => $run_uid,
    run_gid                         => $run_gid,
    options                         => $options,
    additional_options              => $additional_options,
    default_charset                 => $default_charset,
    ssl_mode                        => $ssl_mode,
    htpasswd_file                   => $htpasswd_file,
    htpasswd_path                   => $htpasswd_path,
    ldap_auth                       => $ldap_auth,
    ldap_user                       => $ldap_user,
    mod_security                    => $mod_security,
    mod_security_relevantonly       => $mod_security_relevantonly,
    mod_security_rules_to_disable   => $mod_security_rules_to_disable,
    mod_security_additional_options => $mod_security_additional_options,
  }
}

