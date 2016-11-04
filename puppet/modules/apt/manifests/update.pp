class apt::update inherits ::apt {

  Exec['update_apt'] {
    refreshonly => false
  }

}
