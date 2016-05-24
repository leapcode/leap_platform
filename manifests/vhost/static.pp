# vhost_mode: which option is chosen to deploy the vhost
#   - template: generate it from a template (default)
#   - file: deploy a vhost file (apache::vhost::file will be called directly)
#
# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
#
# mod_security: Whether we use mod_security or not (will include mod_security module)
#    - false: (*default*) don't activate mod_security
#    - true: activate mod_security
#
define apache::vhost::static(
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
    $allow_override                   = 'None',
    $do_includes                      = false,
    $options                          = 'absent',
    $additional_options               = 'absent',
    $default_charset                  = 'absent',
    $ssl_mode                         = false,
    $run_mode                         = 'normal',
    $vhost_mode                       = 'template',
    $template_partial                 = 'apache/vhosts/static/partial.erb',
    $vhost_source                     = 'absent',
    $vhost_destination                = 'absent',
    $htpasswd_file                    = 'absent',
    $htpasswd_path                    = 'absent',
    $mod_security                     = false,
    $mod_security_relevantonly        = true,
    $mod_security_rules_to_disable    = [],
    $mod_security_additional_options  = 'absent'
){
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

    # create vhost configuration file
    ::apache::vhost{$name:
        ensure                          => $ensure,
        configuration                   => $configuration,
        path                            => $path,
        template_partial                => $template_partial,
        vhost_mode                      => $vhost_mode,
        vhost_source                    => $vhost_source,
        vhost_destination               => $vhost_destination,
        domain                          => $domain,
        domainalias                     => $domainalias,
        server_admin                    => $server_admin,
        logmode                         => $logmode,
        allow_override                  => $allow_override,
        do_includes                     => $do_includes,
        options                         => $options,
        additional_options              => $additional_options,
        default_charset                 => $default_charset,
        ssl_mode                        => $ssl_mode,
        htpasswd_file                   => $htpasswd_file,
        htpasswd_path                   => $htpasswd_path,
        mod_security                    => $mod_security,
        mod_security_relevantonly       => $mod_security_relevantonly,
        mod_security_rules_to_disable   => $mod_security_rules_to_disable,
        mod_security_additional_options => $mod_security_additional_options,
    }
}

