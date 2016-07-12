# logmode:
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
#
define apache::vhost::gitweb(
    $ensure = present,
    $configuration = {},
    $domain = 'absent',
    $logmode = 'default',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $owner = root,
    $group = apache,
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0640,
    $allow_override = 'None',
    $template_partial = 'apache/vhosts/gitweb/partial.erb',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $ssl_mode = false,
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent'
){
    # create vhost configuration file
    ::apache::vhost{$name:
        ensure => $ensure,
        configuration => $configuration,
        path => '/var/www/git',
        path_is_webdir => true,
        logpath => $::operatingsystem ? {
            centos => '/var/log/httpd',
            fedora => '/var/log/httpd',
            redhat => '/var/log/httpd',
            openbsd => '/var/www/logs',
            default => '/var/log/apache2'
        },
        logmode => $logmode,
        template_partial => $template_partial,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        allow_override => $allow_override,
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        run_mode => 'normal',
        ssl_mode => $ssl_mode,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        mod_security => false,
    }
}

