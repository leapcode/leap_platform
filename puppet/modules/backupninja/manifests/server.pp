# this define realizes all needed resources for a hosted backup
define backupninja_server_realize($host) {
  User               <<| tag == "backupninja-$host" |>>
  File               <<| tag == "backupninja-$host" |>>
  Ssh_authorized_key <<| tag == "backupninja-$host" |>>
}

class backupninja::server (
  $backupdir = '/backup',
  $backupdir_ensure = 'directory',
  $manage_nagios = false,
  $nagios_server = undef,
  $nagios_warn_level = 129600,
  $nagios_crit_level = 216000,
) {

  group { "backupninjas":
    ensure => "present",
    gid => 700
  }
  
  file { $backupdir:
    ensure => $backupdir_ensure,
    mode => 0710, owner => root, group => "backupninjas",
    require => $backupdir_ensure ? {
      'directory' => undef,
      default     => File["$backupdir_ensure"],
    }
  }

  if $manage_nagios {

    case $nagios_server { undef: { err('Cannot manage nagios without nagios_server parameter!') } }

    include nagios::nsca::client
    
    file { "/usr/local/bin/checkbackups":
      ensure => "present",
      source => "puppet:///modules/backupninja/checkbackups.pl",
      mode => 0755, owner => root, group => root,
    }

    cron { checkbackups:
      command => "/usr/local/bin/checkbackups -d ${backupdir} -s ${nagios_server} -w ${nagios_warn_level} -c ${nagios_crit_level} | grep -v 'sent to host successfully'",
      user => "root",
      hour => "8-23",
      minute => 59,
      require => [ File["/usr/local/bin/checkbackups"], Package['nsca'] ]
    }
  }

  # collect all resources from hosted backups
  Backupninja_server_realize <<| tag == $::fqdn |>>

  # this define allows nodes to declare a remote backup sandbox, that have to
  # get created on the server
  define sandbox (
    $user = $name,
    $host = $::fqdn,
    $installuser = true,
    $dir,
    $manage_ssh_dir = true,
    $ssh_dir = "${dir}/.ssh",
    $authorized_keys_file = 'authorized_keys',
    $key = false,
    $keytype = 'dss',
    $backupkeys = "${fileserver}/keys/backupkeys",
    $uid = false,
    $gid = "backupninjas",
    $backuptag = "backupninja-${::fqdn}",
  ) {

    if !defined(Backupninja_server_realize["${::fqdn}@${host}"]) {
      @@backupninja_server_realize { "${::fqdn}@${host}":
        host => $::fqdn,
        tag  => $host,
      }
    }

    if !defined(File["$dir"]) {
      @@file { "$dir":
        ensure => directory,
        mode => 0750, owner => $user, group => 0,
        tag => "$backuptag",
      }
    }

    if $installuser {

       if $manage_ssh_dir {
        if !defined(File["$ssh_dir"]) {
          @@file { "${ssh_dir}":
            ensure => directory,
            mode => 0700, owner => $user, group => 0,
            require => [User[$user], File["$dir"]],
            tag => "$backuptag",
          }
         }
       } 

      if $key {
        # $key contais ssh public key
        if !defined(Ssh_autorized_key["$user"]) {
          @@ssh_authorized_key{ "$user":
            type    => $keytype,
            key     => $key,
            user    => $user,
            target  => "${ssh_dir}/${authorized_keys_file}",
            tag     => "$backuptag",
            require => User[$user],
          }
        }
      }
      else {
        # get ssh public key exists from server
        if !defined(File["${ssh_dir}/${authorized_keys_file}"]) {
          @@file { "${ssh_dir}/${authorized_keys_file}":
            ensure => present,
            mode => 0644, owner => 0, group => 0,
            source => "${backupkeys}/${user}_id_${keytype}.pub",
            require => File["${ssh_dir}"],
            tag => "$backuptag",
          }
        }
      }
      
      if !defined(User["$user"]) {
        @@user { "$user":
          ensure   => "present",
          uid      => $uid ? {
              false   => undef,
              default => $uid
          },
          gid      => "$gid",
          comment  => "$user backup sandbox",
          home     => "$dir",
          managehome => true,
          shell    => "/bin/bash",
          password => '*',
          require  => Group['backupninjas'],
          tag      => "$backuptag"
        }
      }
    }
  }
}

