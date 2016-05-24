# Safe PGSQL dumps, as part of a backupninja run.
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
#   backupdir, compress, configfile: As defined in the
#   backupninja documentation, with the caveat that hotcopy, sqldump,
#   and compress take true/false rather than yes/no.
# 
define backupninja::pgsql(
  $order = 10, $ensure = present, $databases = 'all', $backupdir = "/var/backups/postgres", $compress = true, $vsname = false)
{
  file { "${backupninja::configdir}/${order}_${name}.pgsql":
    ensure => $ensure,
    content => template('backupninja/pgsql.conf.erb'),
    owner => root,
    group => root,
    mode => 0600,
    require => File["${backupninja::configdir}"]
  }
}
