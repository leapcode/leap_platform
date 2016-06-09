# configure backupninja
class backupninja (
  $ensure_backupninja_version = 'installed',
  $ensure_rsync_version = 'installed',
  $ensure_rdiffbackup_version = 'installed',
  $ensure_debconfutils_version = 'installed',
  $ensure_hwinfo_version = 'installed',
  $ensure_duplicity_version = 'installed',
  $configdir = '/etc/backup.d',
  $keystore = "${::fileserver}/keys/backupkeys",
  $keystorefspath = false,
  $keytype = 'rsa',
  $keydest = '/root/.ssh',
  $keyowner = 0,
  $keygroup = 0,
  $keymanage = true,
  $configfile = '/etc/backupninja.conf',
  $loglvl = 4,
  $when = 'everyday at 01:00',
  $reportemail = 'root',
  $reportsuccess = false,
  $reportwarning = true,
  $reporthost = undef,
  $reportuser = undef,
  $reportdirectory = undef,
  $logfile = '/var/log/backupninja.log',
  $scriptdir = '/usr/share/backupninja',
  $libdir = '/usr/lib/backupninja',
  $usecolors = true,
  $vservers = false,
  $manage_nagios = false,
) {

  # install client dependencies
  ensure_resource('package', 'backupninja', {'ensure' => $ensure_backupninja_version})

  # set up backupninja config directory
  file { $configdir:
    ensure => directory,
    mode   => '0750',
    owner  => 0,
    group  => 0;
  }

  file { $configfile:
    content => template('backupninja/backupninja.conf.erb'),
    owner   => root,
    group   => 0,
    mode    => '0644'
  }

}
