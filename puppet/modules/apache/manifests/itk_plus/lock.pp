class apache::itk_plus::lock {
  # This file resource is used to ensure that only one itk mode is used per host
  file{'/var/www/.itk_mode_lock': ensure => absent }
}
