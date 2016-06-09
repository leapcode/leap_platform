# Run rsync as part of a backupninja run.
# Based on backupninja::rdiff

define backupninja::rsync( $order  = 90,
                           $ensure = present,
                           # [general]
                           $log             = false,
                           $partition       = false,
                           $fscheck         = false,
                           $read_only       = false,
                           $mountpoint      = false,
                           $format          = false,
                           $days            = false,
                           $keepdaily       = false,
                           $keepweekly      = false,
                           $keepmonthly     = false,
                           $lockfile        = false,
                           $nicelevel       = 0,
                           $tmp             = false,
                           $multiconnection = false,
                           $enable_mv_timestamp_bug = false,
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
                           # [dest]
                           $host           = false,
                           $user           = false,
                           $home           = "/home/${user}-${name}",
                           $subfolder      = 'rsync',
                           $testconnect    = false,
                           $ssh            = false,
                           $protocol       = false,
                           $numericids     = false,
                           $compress       = false,
                           $port           = false,
                           $bandwidthlimit = false,
                           $remote_rsync   = false,
                           $batch          = false,
                           $batchbase      = false,
                           $fakesuper      = false,
                           $id_file        = false,
                           # [services]
                           $initscripts = false,
                           $service     = false,
                           # [system]
                           $rm    = false,
                           $cp    = false,
                           $touch = false,
                           $mv    = false,
                           $fsck  = false,
                           # ssh keypair config
                           $key                  = false,
                           $keymanage            = $backupninja::keymanage,
                           $backupkeystore       = $backupninja::keystore,
                           $backupkeytype        = $backupninja::keytype,
                           $ssh_dir_manage       = true,
                           $ssh_dir              = "${home}/.ssh",
                           $authorized_keys_file = 'authorized_keys',
                           # sandbox config
                           $installuser = true,
                           $backuptag   = "backupninja-${::fqdn}",
                           # monitoring
                           $nagios_description = "backups-${name}" ) {

  # install client dependencies
  ensure_resource('package', 'rsync', {'ensure' => $backupninja::ensure_rsync_version})

  # Right now just local origin with remote destination is supported.
  $from = 'local'
  $dest = 'remote'

  case $dest {
    'remote': {
      case $host { false: { err("need to define a host for remote backups!") } }

      $directory = "${home}/${subfolder}/"

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
        keytype              => $backupkeytype,
        backupkeys           => $backupkeystore,
      }
     
      backupninja::key { "${user}-${name}":
        user       => $user,
        keymanage  => $keymanage,
        keytype    => $backupkeytype,
        keystore   => $backupkeystore,
      }
    }
  }

  file { "${backupninja::configdir}/${order}_${name}.rsync":
    ensure  => $ensure,
    content => template('backupninja/rsync.conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0600,
    require => File["${backupninja::configdir}"]
  }

  if $backupninja::manage_nagios {
    nagios::service::passive { $nagios_description: }
  }

}
