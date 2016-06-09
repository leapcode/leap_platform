# Write the backupninja cron job, allowing you to specify an alternate backupninja
# command (if you want to wrap it in any other commands, e.g. to allow it to use
# the monkeysphere for authentication), or a different schedule to run it on.
define backupninja::cron(
  $backupninja_cmd = '/usr/sbin/backupninja',
  $backupninja_test_cmd = $backupninja_cmd,
  $cronfile = "/etc/cron.d/backupninja",
  $min = "0", $hour = "*", $dom = "*", $month = "*",
  $dow = "*")
{
  file { $cronfile:
    content => template('backupninja/backupninja.cron.erb'),
    owner => root,
    group => root,
    mode => 0644
  }
}
