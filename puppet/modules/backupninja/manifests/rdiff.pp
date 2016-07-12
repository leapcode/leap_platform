# Run rdiff-backup as part of a backupninja run.
#
# Valid attributes for this type are:
#
#   order: The prefix to give to the handler config filename, to set
#      order in which the actions are executed during the backup run.
#
#   ensure: Allows you to delete an entry if you don't want it any more
#      (but be sure to keep the configdir, name, and order the same, so
#      that we can find the correct file to remove).
#
#   keep, include, exclude, type, host, directory, user, sshoptions: As
#      defined in the backupninja documentation.  The options will be placed
#      in the correct sections automatically.  The include and exclude
#      options should be given as arrays if you want to specify multiple
#      directories.
# 
define backupninja::rdiff( $order  = 90,
                           $ensure = present,
                           # [general]
                           $options = '--force',
                           $extras  = false,
                           # [source]
                           $include = [ "/var/spool/cron/crontabs",
                                        "/var/backups",
                                        "/etc",
                                        "/root",
                                        "/home",
                                        "/usr/local/*bin",
                                        "/var/lib/dpkg/status*"
                                      ],
                           $exclude = [ "/home/*/.gnupg",
                                        "/home/*/.local/share/Trash",
                                        "/home/*/.Trash",
                                        "/home/*/.thumbnails",
                                        "/home/*/.beagle",
                                        "/home/*/.aMule",
                                        "/home/*/gtk-gnutella-downloads"
                                      ],
                           $vsinclude = false,
                           # [dest]
                           $type       = 'local',
                           $host       = false,
                           $user       = false,
                           $home       = "/home/${user}-${name}",
                           $keep       = 30,
                           $sshoptions = false,
                           # ssh keypair config
                           $key            = false,
                           $keymanage      = $backupninja::keymanage,
                           $backupkeystore = $backupninja::keystore,
                           $backupkeytype  = $backupninja::keytype,
                           $ssh_dir_manage = true,
                           $ssh_dir        = "${home}/.ssh",
                           $authorized_keys_file = 'authorized_keys',
                           # sandbox config
                           $installuser = true,
                           $backuptag   = "backupninja-${::fqdn}",
                           # monitoring
                           $nagios_description = "backups-${name}" ) {

  # install client dependencies
  ensure_resource('package', 'rdiff-backup', {'ensure' => $backupninja::ensure_rdiffbackup_version})

  $directory = "$home/$name/"

  case $type {
    'remote': {
      case $host { false: { err("need to define a host for remote backups!") } }

      backupninja::server::sandbox { "${user}-${name}":
        user                 => $user,
        host                 => $host,
        dir                  => $home,
        manage_ssh_dir       => $ssh_dir_manage,
        ssh_dir              => $ssh_dir,
        key                  => $key,
        authorized_keys_file => $authorized_keys_file,
        installuser          => $installuser,
        backuptag            => $backuptag,
        backupkeys           => $backupkeystore,
        keytype              => $backupkeytype,
      }
     
      backupninja::key { "${user}-${name}":
        user      => $user,
        keymanage => $keymanage,
        keytype   => $backupkeytype,
        keystore  => $backupkeystore,
      }
    }
  }


  file { "${backupninja::configdir}/${order}_${name}.rdiff":
    ensure  => $ensure,
    content => template('backupninja/rdiff.conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0600,
    require => File["${backupninja::configdir}"]
  }

  if $backupninja::manage_nagios {
    nagios::service::passive { $nagios_description: }
  }

}
  
