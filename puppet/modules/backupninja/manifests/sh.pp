# sh handler, as part of a backupninja run.
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
define backupninja::sh($order = 50,
                           $ensure = present,
                           $command_string
                          ) {
	file { "${backupninja::configdir}/${order}_${name}.sh":
		ensure => $ensure,
		content => template('backupninja/sh.conf.erb'),
		owner => root,
		group => root,
		mode => 0600,
		require => File["${backupninja::configdir}"]
	}
}
