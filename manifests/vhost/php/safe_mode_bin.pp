# safe_mode binaries
define apache::vhost::php::safe_mode_bin(
  $ensure = 'present',
  $path
){
  $substr=regsubst($name,'^.*\/','','G')
  $real_path = "${path}/${substr}"
  $target = $ensure ? {
    'present' => regsubst($name,'^.*@',''),
    default => absent,
  }
  file{$real_path:
    ensure => link,
    target => $target,
  }
}

