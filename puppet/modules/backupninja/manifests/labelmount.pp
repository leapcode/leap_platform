# Mount a labelled partition on a directory as part of a backupninja run.
#
# This type will automatically create an unmount action with an order of 99
# for the destination directory you specify here.
#
# Valid attributes for this type are:
#
#   order: The prefix to give to the handler config filename, to set
#      order in which the actions are executed during the backup run.  Note
#      that the value given here should be less than any action which
#      requires the filesystem to be mounted!
#
#   ensure: Allows you to delete an entry if you don't want it any more
#      (but be sure to keep the configdir, name, and order the same, so
#      that we can find the correct file to remove).
#
#   label: The partition label to mount.
#
#   dest: The directory to mount the partition onto.
# 
define backupninja::labelmount($order = 10,
                               $ensure = present,
                               $label,
                               $dest
                              ) {
	file { "${backupninja::configdir}/${order}_${name}.labelmount":
		ensure => $ensure,
		content => template('backupninja/labelmount.conf.erb'),
		owner => root,
		group => root,
		mode => 0600,
		require => File["${backupninja::configdir}"]
	}

	file { "${backupninja::configdir}/99_${name}.umount":
		ensure => $ensure,
		content => template('backupninja/umount.conf.erb'),
		owner => root,
		group => root,
		mode => 0600,
		require => File["${backupninja::configdir}"]
	}
	
	# Copy over the handler scripts themselves, since they're not in the
	# standard distribution, and are unlikely to end up there any time
	# soon because backupninja's "build" system is balls.
	file { "/usr/share/backupninja/labelmount":
		content => template('backupninja/labelmount.handler'),
		owner => root,
		group => root,
		mode => 0755,
		require => Package[backupninja]
	}

	file { "/usr/share/backupninja/umount":
		content => template('backupninja/umount.handler'),
		owner => root,
		group => root,
		mode => 0755,
		require => Package[backupninja]
	}
}
