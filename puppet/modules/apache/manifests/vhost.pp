# this is a wrapper for apache::vhost::file and avhost::template below
#
# vhost_mode: which option is choosed to deploy the vhost
#   - template: generate it from a template (default)
#   - file: deploy a vhost file (apache::vhost::file will be called directly)
#
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
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
#
# mod_security: Whether we use mod_security or not (will include mod_security module)
#    - false: (*default*) don't activate mod_security
#    - true: activate mod_security
#
define apache::vhost(
    $ensure                           = present,
    $configuration                    = {},
    $path                             = 'absent',
    $path_is_webdir                   = false,
    $logpath                          = 'absent',
    $logmode                          = 'default',
    $logprefix                        = '',
    $vhost_mode                       = 'template',
    $template_partial                 = 'apache/vhosts/static/partial.erb',
    $vhost_source                     = 'absent',
    $vhost_destination                = 'absent',
    $content                          = 'absent',
    $domain                           = 'absent',
    $domainalias                      = 'absent',
    $server_admin                     = 'absent',
    $allow_override                   = 'None',
    $php_settings                     = {},
    $php_options                      = {},
    $cgi_binpath                      = 'absent',
    $default_charset                  = 'absent',
    $do_includes                      = false,
    $options                          = 'absent',
    $additional_options               = 'absent',
    $run_mode                         = 'normal',
    $run_uid                          = 'absent',
    $run_gid                          = 'absent',
    $ssl_mode                         = false,
    $htpasswd_file                    = 'absent',
    $htpasswd_path                    = 'absent',
    $mod_security                     = true,
    $mod_security_relevantonly        = true,
    $mod_security_rules_to_disable    = [],
    $mod_security_additional_options  = 'absent',
    $use_mod_macro                    = false,
    $ldap_auth                        = false,
    $ldap_user                        = 'any',
    $passing_extension                = 'absent',
    $gempath                          = 'absent'
) {
    # file or template mode?
    case $vhost_mode {
        'file': {
            apache::vhost::file{$name:
                ensure            => $ensure,
                configuration     => $configuration,
                vhost_source      => $vhost_source,
                vhost_destination => $vhost_destination,
                do_includes       => $do_includes,
                run_mode          => $run_mode,
                mod_security      => $mod_security,
                htpasswd_file     => $htpasswd_file,
                htpasswd_path     => $htpasswd_path,
                use_mod_macro     => $use_mod_macro,
            }
        }
        'template': {
            apache::vhost::template{$name:
                ensure                          => $ensure,
                configuration                   => $configuration,
                path                            => $path,
                path_is_webdir                  => $path_is_webdir,
                logpath                         => $logpath,
                logmode                         => $logmode,
                logprefix                       => $logprefix,
                domain                          => $domain,
                domainalias                     => $domainalias,
                server_admin                    => $server_admin,
                cgi_binpath                     => $cgi_binpath,
                allow_override                  => $allow_override,
                do_includes                     => $do_includes,
                options                         => $options,
                additional_options              => $additional_options,
                default_charset                 => $default_charset,
                php_settings                    => $php_settings,
                php_options                     => $php_options,
                run_mode                        => $run_mode,
                run_uid                         => $run_uid,
                run_gid                         => $run_gid,
                template_partial                => $template_partial,
                ssl_mode                        => $ssl_mode,
                htpasswd_file                   => $htpasswd_file,
                htpasswd_path                   => $htpasswd_path,
                ldap_auth                       => $ldap_auth,
                ldap_user                       => $ldap_user,
                mod_security                    => $mod_security,
                mod_security_relevantonly       => $mod_security_relevantonly,
                mod_security_rules_to_disable   => $mod_security_rules_to_disable,
                mod_security_additional_options => $mod_security_additional_options,
                use_mod_macro                   => $use_mod_macro,
                passing_extension               => $passing_extension,
                gempath                         => $gempath,
            }
        }
        default: { fail("No such vhost_mode: ${vhost_mode} defined for ${name}.") }
    }
}
