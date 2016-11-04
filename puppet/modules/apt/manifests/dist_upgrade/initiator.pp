class apt::dist_upgrade::initiator inherits apt::dist_upgrade {

  $initiator = 'upgrade_initiator'
  $initiator_abs = "${apt::apt_base_dir}/${initiator}"

  file { 'apt_upgrade_initiator':
    mode     => '0644',
    owner    => root,
    group    => 0,
    path     => $initiator_abs,
    checksum => md5,
    source   => [
                  "puppet:///modules/site_apt/${::fqdn}/${initiator}",
                  "puppet:///modules/site_apt/${initiator}",
                  "puppet:///modules/apt/${initiator}",
                ],
  }

  Exec['apt_dist-upgrade'] {
    subscribe +> File['apt_upgrade_initiator'],
  }

}
