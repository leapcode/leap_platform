# xml simple lib
class rubygems::xmlsimple {
  package{'rubygem-xml-simple':
    ensure => present,
  }
  case $::operatingsystem {
    debian,ubuntu: {
      Package['rubygem-xml-simple']{
        name => 'libxml-simple-ruby'
      }
    }
  }
  if $::operatingsystem == 'CentOS' and versioncmp($::operatingsystemrelease, '6') > 0 {
    # not yet packaged
    Package['rubygem-xml-simple']{
      name     => 'xml-simple',
      provider => gem,
    }
  }
}
