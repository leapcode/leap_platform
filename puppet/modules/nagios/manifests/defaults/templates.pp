# manage nagios_templates
class nagios::defaults::templates {
  include nagios::defaults::vars

  file { 'nagios_templates':
    path    => "${nagios::defaults::vars::int_cfgdir}/nagios_templates.cfg",
    source  => [ "puppet:///modules/site_nagios/configs/${::fqdn}/nagios_templates.cfg",
      "puppet:///modules/site_nagios/configs/${::operatingsystem}/nagios_templates.cfg",
      'puppet:///modules/site_nagios/configs/nagios_templates.cfg',
      "puppet:///modules/nagios/configs/${::operatingsystem}/nagios_templates.cfg",
      'puppet:///modules/nagios/configs/nagios_templates.cfg' ],
    notify  => Service['nagios'],
    owner   => root,
    group   => root,
    mode    => '0644';
  }
}
