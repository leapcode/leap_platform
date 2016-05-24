class git::base {

  package { 'git':
    ensure => present,
    alias => 'git',
  }
}
