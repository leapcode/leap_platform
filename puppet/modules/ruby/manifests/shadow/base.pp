class ruby::shadow::base {
  require ::ruby
  package{'ruby-shadow':
    ensure => installed,
  }
}
