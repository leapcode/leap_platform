class apt::params () {
  $use_lts = false
  $use_volatile = false
  $use_backports = true
  $include_src = false
  $use_next_release = false
  $debian_url = 'http://httpredir.debian.org/debian/'
  $security_url = 'http://security.debian.org/'
  $ubuntu_url = 'http://archive.ubuntu.com/ubuntu'
  $backports_url = $::debian_codename ? {
    'squeeze'  => 'http://backports.debian.org/debian-backports/',
    default => $::operatingsystem ? {
      'Ubuntu' => $ubuntu_url,
      default  => $debian_url,
    }
  }
  $lts_url = $debian_url
  $volatile_url = 'http://volatile.debian.org/debian-volatile/'
  $repos = 'auto'
  $custom_preferences = ''
  $custom_key_dir = false
}
