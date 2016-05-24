# Handle files that are specifically needed for nagios with apache on debian
#
# Do not include this class directly. It is included by the nagios class and
# needs variables from it.
#
class nagios::debian::apache {

  include ::nagios::defaults::vars

  file { "${nagios::defaults::vars::int_cfgdir}/apache2.conf":
    source => [ "puppet:///modules/site_nagios/configs/${::fqdn}/apache2.conf",
                'puppet:///modules/site_nagios/configs/apache2.conf',
                'puppet:///modules/nagios/configs/apache2.conf'],
  }

  apache::config::global { 'nagios3.conf':
    ensure  => link,
    target  => "${nagios::defaults::vars::int_cfgdir}/apache2.conf",
    require => File["${nagios::defaults::vars::int_cfgdir}/apache2.conf"],
  }

}
