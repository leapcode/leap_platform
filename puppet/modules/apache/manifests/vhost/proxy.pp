# Proxy VHost
# Parameters:
#
# - ensure: wether this vhost is `present` or `absent`
# - domain: the domain to redirect (*name*)
# - domainalias: A list of whitespace seperated domains to redirect
# - target_url: the url to be proxied. Note: We don't want http://example.com/foobar only example.com/foobar
# - server_admin: the email that is shown as responsible
# - ssl_mode: wether this vhost supports ssl or not
#   - false: don't enable ssl for this vhost (default)
#   - true: enable ssl for this vhost
#   - force: enable ssl and redirect non-ssl to ssl
#   - only: enable ssl only
#
# logmode:
#
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
#
define apache::vhost::proxy(
    $ensure = present,
    $configuration = {},
    $domain = 'absent',
    $domainalias = 'absent',
    $htpasswd_file = 'absent',
    $target_url,
    $server_admin = 'absent',
    $logmode = 'default',
    $mod_security = false,
    $ssl_mode = false,
    $mod_security_relevantonly = true,
    $mod_security_rules_to_disable = [],
    $mod_security_additional_options = 'absent',
    $additional_options = 'absent'
){
    # create vhost configuration file
    # we use the options field as the target_url
    ::apache::vhost::template{$name:
        ensure => $ensure,
        configuration => $configuration,
        template_partial => 'apache/vhosts/proxy/partial.erb',
        domain => $domain,
        path => 'really_absent',
        path_is_webdir => true,
        htpasswd_file => $htpasswd_file,
        domainalias => $domainalias,
        server_admin => $server_admin,
        logpath => $::operatingsystem ? {
          openbsd => '/var/www/logs',
          centos => '/var/log/httpd',
          default => '/var/log/apache2'
        },
        logmode => $logmode,
        allow_override => $allow_override,
        run_mode => 'normal',
        mod_security => $mod_security,
        mod_security_relevantonly => $mod_security_relevantonly,
        mod_security_rules_to_disable => $mod_security_rules_to_disable,
        mod_security_additional_options => $mod_security_additional_options,
        options => $target_url,
        ssl_mode => $ssl_mode,
        additional_options => $additional_options,
    }
}

