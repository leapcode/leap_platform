class rubygems::highline {
  require rubygems
  package{'rubygem-highline':
    ensure => present,
  }

  case $::operatingsystem {
    debian,ubuntu: {
      Package['rubygem-highline']{
        name => 'ruby-highline'
      }
    }
  }
}
