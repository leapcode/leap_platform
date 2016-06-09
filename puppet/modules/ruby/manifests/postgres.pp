class ruby::postgres {
  include ruby
  package{'ruby-postgres':
    ensure => installed,
  }
}
