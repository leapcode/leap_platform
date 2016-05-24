define apache::vhost::file::documentrootdir(
      $ensure = directory,
      $documentroot,
      $filename,
      $thedomain,
      $owner = 'root',
      $group = '0',
      $mode = 440
){
  file{"$documentroot/$filename":
    require => Apache::Vhost::Webdir["$thedomain"],
    owner => $owner, group => $group, mode => $mode;
  }
  if $ensure != 'absent' {
    File["$documentroot/$filename"]{
      ensure => directory,
    }
  } else {
    File["$documentroot/$filename"]{
      ensure => $ensure,
    }
  }
}

