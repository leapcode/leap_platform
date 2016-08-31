# remove possible leftovers on soledad nodes
class site_config::remove::soledad {

  # remove soledad procs check because leap_cli already checks for them
  augeas { 'Soledad_Procs':
    incl    => '/etc/check_mk/mrpe.cfg',
    lens    => 'Spacevars.lns',
    changes => [ 'rm /files/etc/check_mk/mrpe.cfg/Soledad_Procs' ],
    require => File['/etc/check_mk/mrpe.cfg'];
  }

}
