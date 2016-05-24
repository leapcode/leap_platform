# Run duplicity-backup as part of a backupninja run.
#
# Valid attributes for this type are:
#
#   order:
#
#      The prefix to give to the handler config filename, to set order in
#      which the actions are executed during the backup run.
#
#   ensure:
#
#      Allows you to delete an entry if you don't want it any more (but be
#      sure to keep the configdir, name, and order the same, so that we can
#      find the correct file to remove).
#
#   options, nicelevel, testconnect, tmpdir, sign, encryptkey, signkey,
#   password, include, exclude, vsinclude, incremental, keep, bandwidthlimit,
#   sshoptions, destdir, desthost, desuser:
#
#      As defined in the backupninja documentation.  The options will be
#      placed in the correct sections automatically.  The include and
#      exclude options should be given as arrays if you want to specify
#      multiple directories.
#
#   directory, ssh_dir_manage, ssh_dir, authorized_keys_file, installuser,
#   installkey, backuptag:
#
#      Options for the bakupninja::server::sandbox define, check that
#      definition for more info.
#
# Some notes about this handler:
#
#   - When specifying a password, be sure to enclose it in single quotes,
#     this is particularly important if you have any special characters, such
#     as a $ which puppet will attempt to interpret resulting in a different
#     password placed in the file than you expect!
#   - There's no support for a 'local' type in backupninja's duplicity
#     handler on version 0.9.6-4, which is the version available in stable and
#     testing debian repositories by the time of this writing.
define backupninja::duplicity( $order  = 90,
                               $ensure = present,
                               # options to the config file
                               $options     = false,
                               $nicelevel   = false,
                               $testconnect = false,
                               $tmpdir      = false,
                               # [gpg]
                               $sign       = false,
                               $encryptkey = false,
                               $signkey    = false,
                               $password   = false,
                               # [source]
                               $include = [ "/var/spool/cron/crontabs",
                                            "/var/backups",
                                            "/etc",
                                            "/root",
                                            "/home",
                                            "/usr/local/*bin",
                                            "/var/lib/dpkg/status*" ],
                               $exclude = [ "/home/*/.gnupg",
                                            "/home/*/.local/share/Trash",
                                            "/home/*/.Trash",
                                            "/home/*/.thumbnails",
                                            "/home/*/.beagle",
                                            "/home/*/.aMule",
                                            "/home/*/.gnupg",
                                            "/home/*/.gpg",
                                            "/home/*/.ssh",
                                            "/home/*/gtk-gnutella-downloads",
                                            "/etc/ssh/*" ],
                               $vsinclude = false,
                               # [dest]
                               $incremental   = "yes",
                               $increments   = false,
                               $keep          = false,
                               $keepincroffulls = false,
                               $bandwidthlimit = false,
                               $sshoptions    = false,
                               $destdir       = false,
                               $desthost      = false,
                               $destuser      = false,
                               $desturl       = false,
                               # configs to backupninja client
                               $backupkeystore       = $backupninja::keystore,
                               $backupkeystorefspath = $backupninja::keystorefspath,
                               $backupkeytype        = $backupninja::keytype,
                               $backupkeydest        = $backupninja::keydest,
                               $backupkeydestname    = $backupninja::keydestname,
                               # options to backupninja server sandbox
                               $ssh_dir_manage       = true,
                               $ssh_dir              = "${destdir}/.ssh",
                               $authorized_keys_file = 'authorized_keys',
                               $installuser          = true,
                               $backuptag            = "backupninja-${::fqdn}",
                               # key options
                               $createkey            = false,
                               $keymanage            = $backupninja::keymanage ) {

  # install client dependencies
  ensure_resource('package', 'duplicity', {'ensure' => $backupninja::ensure_duplicity_version})

  case $desthost { false: { err("need to define a destination host for remote backups!") } }
  case $destdir { false: { err("need to define a destination directory for remote backups!") } }
  case $password { false: { err("a password is necessary either to unlock the GPG key, or for symmetric encryption!") } }

  # guarantees there's a configured backup space for this backup
  backupninja::server::sandbox { "${user}-${name}":
    user                 => $destuser,
    host                 => $desthost,
    dir                  => $destdir,
    manage_ssh_dir       => $ssh_dir_manage,
    ssh_dir              => $ssh_dir,
    authorized_keys_file => $authorized_keys_file,
    installuser          => $installuser,
    backuptag            => $backuptag,
    backupkeys           => $backupkeystore,
    keytype              => $backupkeytype,
  }

  # the client's ssh key
  backupninja::key { "${destuser}-${name}":
    user           => $destuser,
    createkey      => $createkey,
    keymanage      => $keymanage,
    keytype        => $backupkeytype,
    keystore       => $backupkeystore,
    keystorefspath => $backupkeystorefspath,
    keydest        => $backupkeydest,
    keydestname    => $backupkeydestname
  }

  # the backupninja rule for this duplicity backup
  file { "${backupninja::configdir}/${order}_${name}.dup":
    ensure  => $ensure,
    content => template('backupninja/dup.conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0600,
    require => File["${backupninja::configdir}"]
  }

  if $backupninja::manage_nagios {
    nagios::service::passive { $nagios_description: }
  }

}

