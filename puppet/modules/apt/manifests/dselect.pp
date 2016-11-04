# manage dselect, like
# suppressing the annoying help texts
class apt::dselect {

  file_line { 'dselect_expert':
    path => '/etc/dpkg/dselect.cfg',
    line => 'expert',
  }

  package { 'dselect': ensure => installed }
}
