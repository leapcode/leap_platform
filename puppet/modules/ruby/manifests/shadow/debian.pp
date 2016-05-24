class ruby::shadow::debian inherits ruby::shadow::base {
  Package['ruby-shadow']{
    name =>  $::lsbdistcodename ? {
      'wheezy' => 'libshadow-ruby1.8',
      default  => 'ruby-shadow',
    }
  }
}
