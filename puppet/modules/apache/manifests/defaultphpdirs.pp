# setup some directories for php
class apache::defaultphpdirs {
    file{
      '/var/www/upload_tmp_dir':
        ensure  => directory,
        require => Package['apache'],
        owner   => root,
        group   => 0,
        mode    => '0755';
      '/var/www/session.save_path':
        ensure  => directory,
        require => Package['apache'],
        owner   => root,
        group   => 0,
        mode    => '0755';
    }

    if str2bool($::selinux) {
      $seltype_rw = $::operatingsystemmajrelease ? {
        5       => 'httpd_sys_script_rw_t',
        default => 'httpd_sys_rw_content_t'
      }
      selinux::fcontext{
        [ '/var/www/upload_tmp_dir/.+(/.*)?',
          '/var/www/session.save_path/.+(/.*)?' ]:
          require => Package['apache'],
          setype  => $seltype_rw,
          before  => File['/var/www/upload_tmp_dir','/var/www/session.save_path'];
      }
    }
}
