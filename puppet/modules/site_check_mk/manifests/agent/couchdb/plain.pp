# configure logwatch and nagios checks for plain single couchdb master
class site_check_mk::agent::couchdb::plain {

  # remove bigcouch leftovers
  augeas {
    'Bigcouch_epmd_procs':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => 'rm /files/etc/check_mk/mrpe.cfg/Bigcouch_epmd_procs',
      require => File['/etc/check_mk/mrpe.cfg'];
    'Bigcouch_beam_procs':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => 'rm /files/etc/check_mk/mrpe.cfg/Bigcouch_beam_procs',
      require => File['/etc/check_mk/mrpe.cfg'];
    'Bigcouch_open_files':
      incl    => '/etc/check_mk/mrpe.cfg',
      lens    => 'Spacevars.lns',
      changes => 'rm /files/etc/check_mk/mrpe.cfg/Bigcouch_open_files',
      require => File['/etc/check_mk/mrpe.cfg'];
  }

}
