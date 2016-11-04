# sys handler, as part of a backupninja run.
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
# 
define backupninja::sys($order = 30,
                           $ensure = present,
                           $parentdir = '/var/backups',
                           $packages = true,
                           $packagesfile = '/var/backups/dpkg-selections.txt',
                           $partitions = true,
                           $partitionsfile = '/var/backups/partitions.__star__.txt',
                           $dosfdisk = true,
                           $hardware = true,
                           $hardwarefile = '/var/backups/hardware.txt',
                           $dohwinfo = true,
                           $doluks = false,
                           $dolvm = false
                          ) {

  # install client dependencies
  case $operatingsystem {
    debian,ubuntu: {
      ensure_resource('package', 'debconf-utils', {'ensure' => $backupninja::ensure_debconfutils_version})
      ensure_resource('package', 'hwinfo', {'ensure' => $backupninja::ensure_hwinfo_version})
    }
    default: {}
  }

	file { "${backupninja::configdir}/${order}_${name}.sys":
		ensure => $ensure,
		content => template('backupninja/sys.conf.erb'),
		owner => root,
		group => root,
		mode => 0600,
		require => File["${backupninja::configdir}"]
	}
}
