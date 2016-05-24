define apache::vhost::phpdirs(
  $ensure = present,
  $php_upload_tmp_dir,
  $php_session_save_path,
  $documentroot_owner = apache,
  $documentroot_group = 0,
  $documentroot_mode = 0750,
  $run_mode = 'normal',
  $run_uid = 'absent'
){
  case $ensure {
    absent : {
      file {
        [$php_upload_tmp_dir, $php_session_save_path] :
          ensure => absent,
          purge => true,
          force => true,
          recurse => true,
      }
    }
    default : {
      include apache::defaultphpdirs
      file {
        [$php_upload_tmp_dir, $php_session_save_path] :
          ensure => directory,
          owner => $run_mode ? {
            'itk' => $run_uid,
            'static-itk' => $run_uid,
            'proxy-itk' => $run_uid,
            'fcgid' => $run_uid,
            default => $documentroot_owner
          },
          group => $documentroot_group,
          mode => $documentroot_mode ;
      }
    }
  }
}

