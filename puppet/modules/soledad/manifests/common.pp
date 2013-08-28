class soledad::common {

  include soledad

  package { 'soledad-common':
    ensure  => latest,
    require => User['soledad']
  }

}
