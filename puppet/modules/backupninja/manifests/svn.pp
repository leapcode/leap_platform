# Subversion dumps, as part of a backupninja run.
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
define backupninja::svn($order = 20,
                           $ensure = present,
                           $src = '/var/lib/svn',
                           $dest = '/var/backups/svn',
                           $tmp = '/var/backups/svn.tmp',
                           $vsname = false
                          ) {
	file { "${backupninja::configdir}/${order}_${name}.svn":
		ensure => $ensure,
		content => template('backupninja/svn.conf.erb'),
		owner => root,
		group => root,
		mode => 0600,
		require => File["${backupninja::configdir}"]
	}
}
