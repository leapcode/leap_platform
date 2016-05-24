define apt::upgrade_package (
  $version = ''
) {

  $version_suffix = $version ? {
    ''       => '',
    'latest' => '',
    default  => "=${version}",
  }

  if !defined(Package['apt-show-versions']) {
    package { 'apt-show-versions':
      ensure  => installed,
      require => undef,
    }
  }

  if !defined(Package['dctrl-tools']) {
    package { 'dctrl-tools':
      ensure  => installed,
      require => undef,
    }
  }

  exec { "apt-get -q -y -o 'DPkg::Options::=--force-confold' install ${name}${version_suffix}":
    onlyif  => [ "grep-status -F Status installed -a -P $name -q", "apt-show-versions -u $name | grep -q upgradeable" ],
    require => Package['apt-show-versions', 'dctrl-tools'],
    before  => Exec['apt_updated']
  }

}
