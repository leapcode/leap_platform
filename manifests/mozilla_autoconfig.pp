# setup autoconfig infos
#
# this will create a global autoconfig file, that maps
# any of your hosted domains on this host to a certain
# provider configuration. Which means, that you get a zero
# setup autoconfig for any domain that you host the website
# and the emails for.
# By default you only need to define the provider, which
# is usually your main domain. Everything else should be
# derived from that.
# You can however still fine tune things from it.
class apache::mozilla_autoconfig(
  $provider,
  $display_name      = undef,
  $shortname         = undef,
  $imap_server       = undef,
  $pop_server        = undef,
  $smtp_server       = undef,
  $documentation_url = undef,
) {
  apache::config::global { 'mozilla_autoconfig.conf': }

  file{
    '/var/www/autoconfig':
      ensure  => directory,
      require => Package['apache'],
      owner   => root,
      group   => apache,
      mode    => '0640';
  '/var/www/autoconfig/config.shtml':
      content => template('apache/webfiles/autoconfig/config.shtml.erb'),
      owner   => root,
      group   => apache,
      mode    => '0640',
      before  => Service['apache'],
  }
}
