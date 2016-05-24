class couchdb::bigcouch::package::cloudant (
  $ensure = 'present'
) {

  # cloudant's signing key can be fetched from
  # http://packages.cloudant.com/KEYS, please use the apt module to
  # distribute it on your servers after verifying its fingerprint

  # cloudant's wheezy repo will fail cause in their Release file
  # (http://packages.cloudant.com/debian/dists/wheezy/Release) they
  # wrongly marked the packages for squeeze
  # so we will use their squeeze repo here
  apt::sources_list {'bigcouch-cloudant.list':
    ensure  => $ensure,
    content => 'deb http://packages.cloudant.com/debian squeeze main'
  }

  # right now, cloudant only provides authenticated bigcouch 0.4.2 packages
  # for squeeze, therefore we need to allow the installation of the depending
  # packages libicu44 and libssl0.9.8 from squeeze

  if $::lsbdistcodename == 'wheezy' {
    apt::sources_list {'squeeze.list':
      ensure  => $ensure,
      content => 'deb http://http.debian.net/debian squeeze main
deb http://security.debian.org/ squeeze/updates main
'   }
    apt::preferences_snippet { 'bigcouch_squeeze_deps':
      ensure   => $ensure,
      package  => 'libicu44 libssl0.9.8',
      priority => '980',
      pin      => 'release o=Debian,n=squeeze'
    }
  }
}
