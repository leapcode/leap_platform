# run_uid: the uid the vhost should run as with the mod_passenger module
# run_gid: the gid the vhost should run as with the mod_passenger module
#
# logmode:
#
#   - default: Do normal logging to CustomLog and ErrorLog
#   - nologs: Send every logging to /dev/null
#   - anonym: Don't log ips for CustomLog, send ErrorLog to /dev/null
#   - semianonym: Don't log ips for CustomLog, log normal ErrorLog
#
# mod_security: Whether we use mod_security or not (will include mod_security module)
#    - false: don't activate mod_security
#    - true: (*defaul*) activate mod_security
#
define apache::vhost::passenger(
    $ensure = present,
    $configuration = {},
    $domain = 'absent',
    $domainalias = 'absent',
    $server_admin = 'absent',
    $logmode = 'default',
    $path = 'absent',
    $manage_webdir = true,
    $manage_docroot = true,
    $owner = root,
    $group = apache,
    $documentroot_owner = apache,
    $documentroot_group = 0,
    $documentroot_mode = 0640,
    $run_uid = 'absent',
    $run_gid = 'absent',
    $allow_override = 'None',
    $do_includes = false,
    $options = 'absent',
    $additional_options = 'absent',
    $default_charset = 'absent',
    $mod_security = true,
    $mod_security_relevantonly = true,
    $mod_security_rules_to_disable = [],
    $mod_security_additional_options = 'absent',
    $ssl_mode = false,
    $vhost_mode = 'template',
    $template_partial = 'apache/vhosts/passenger/partial.erb',
    $vhost_source = 'absent',
    $vhost_destination = 'absent',
    $htpasswd_file = 'absent',
    $htpasswd_path = 'absent',
    $passenger_ree = false,
    $passenger_app = 'rails'
){

    if $passenger_ree {
      include ::passenger::ree::apache
    } else {
      include ::passenger::apache
    }

    if $manage_webdir {
      # create webdir
      ::apache::vhost::webdir{$name:
        ensure => $ensure,
        path => $path,
        owner => $owner,
        group => $group,
        mode => 0644,
        run_mode => 'normal',
        manage_docroot => $manage_docroot,
        documentroot_owner => $documentroot_owner,
        documentroot_group => $run_gid,
        documentroot_mode => $documentroot_mode,
      }
    }
    $real_path = $path ? {
        'absent' => $::operatingsystem ? {
            openbsd => "/var/www/htdocs/${name}",
            default => "/var/www/vhosts/${name}"
        },
        default => $path
    }
    file{
      ["${real_path}/www/tmp", "${real_path}/www/log"]:
        ensure => directory,
        owner => $documentroot_owner, group => $run_gid, mode => 0660;
      ["${real_path}/www/public", "${real_path}/gems"]:
        ensure => directory,
        owner => $documentroot_owner, group => $run_gid, mode => 0640;
    }
    if $passenger_app == 'rails' {
      file{
        "${real_path}/www/config":
          ensure => directory,
          owner => $documentroot_owner, group => $run_gid, mode => 0640;
        "${real_path}/www/config/environment.rb":
          ensure => present,
          owner => $run_uid, group => $run_gid, mode => 0640;
      }
    } else {
      #rack based
      file{
        "${real_path}/www/config.ru":
          ensure => present,
          owner => $run_uid, group => $run_gid, mode => 0640;
      }
    }

    # create vhost configuration file
    ::apache::vhost{$name:
        ensure => $ensure,
        configuration => $configuration,
        path => "${real_path}/www/public",
        path_is_webdir => true,
        template_partial => $template_partial,
        logmode => $logmode,
        logpath => "${real_path}/logs",
        vhost_mode => $vhost_mode,
        vhost_source => $vhost_source,
        vhost_destination => $vhost_destination,
        domain => $domain,
        domainalias => $domainalias,
        server_admin => $server_admin,
        run_mode => 'normal',
        run_uid => $run_uid,
        run_gid => $run_gid,
        allow_override => $allow_override,
        do_includes => $do_includes,
        options => $options,
        additional_options => $additional_options,
        default_charset => $default_charset,
        ssl_mode => $ssl_mode,
        htpasswd_file => $htpasswd_file,
        htpasswd_path => $htpasswd_path,
        mod_security => $mod_security,
        mod_security_relevantonly => $mod_security_relevantonly,
        mod_security_rules_to_disable => $mod_security_rules_to_disable,
        mod_security_additional_options => $mod_security_additional_options,
        gempath => "${real_path}/gems"
    }
}

