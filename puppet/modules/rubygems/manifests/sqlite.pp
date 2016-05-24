class rubygems::sqlite {
  require rubygems::devel
  package{'rubygem-sqlite3-ruby':
    ensure => present,
  }
}
