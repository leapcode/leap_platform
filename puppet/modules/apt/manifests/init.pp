# apt.pp - common components and defaults for handling apt
# Copyright (C) 2008 Micah Anerson <micah@riseup.net>
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class apt(
  $use_lts = $apt::params::use_lts,
  $use_volatile = $apt::params::use_volatile,
  $use_backports = $apt::params::use_backports,
  $include_src = $apt::params::include_src,
  $use_next_release = $apt::params::use_next_release,
  $debian_url = $apt::params::debian_url,
  $security_url = $apt::params::security_url,
  $backports_url = $apt::params::backports_url,
  $lts_url = $apt::params::lts_url,
  $volatile_url = $apt::params::volatile_url,
  $ubuntu_url = $apt::params::ubuntu_url,
  $repos = $apt::params::repos,
  $custom_preferences = $apt::params::custom_preferences,
  $custom_sources_list = '',
  $custom_key_dir = $apt::params::custom_key_dir
) inherits apt::params {
  case $::operatingsystem {
    'debian': {
      $real_repos = $repos ? {
        'auto'  => 'main contrib non-free',
        default => $repos,
      }
    }
    'ubuntu': {
      $real_repos = $repos ? {
        'auto'  => 'main restricted universe multiverse',
        default => $repos,
      }
    }
  }

  package { 'apt':
    ensure  => installed,
    require => undef,
  }

  $sources_content = $custom_sources_list ? {
    ''      => template( "apt/${::operatingsystem}/sources.list.erb"),
    default => $custom_sources_list
  }
  file {
    # include main and security
    # additional sources should be included via the apt::sources_list define
    '/etc/apt/sources.list':
      content => $sources_content,
      notify  => Exec['apt_updated'],
      owner   => root,
      group   => 0,
      mode    => '0644';
  }

  apt_conf { '02show_upgraded':
    source => [ "puppet:///modules/site_apt/${::fqdn}/02show_upgraded",
                'puppet:///modules/site_apt/02show_upgraded',
                'puppet:///modules/apt/02show_upgraded' ]
  }

  if ( $::virtual == 'vserver' ) {
    apt_conf { '03clean_vserver':
      source => [ "puppet:///modules/site_apt/${::fqdn}/03clean_vserver",
                  'puppet:///modules/site_apt/03clean_vserver',
                  'puppet:///modules/apt/03clean_vserver' ],
      alias => '03clean';
    }
  }
  else {
    apt_conf { '03clean':
      source => [ "puppet:///modules/site_apt/${::fqdn}/03clean",
                  'puppet:///modules/site_apt/03clean',
                  'puppet:///modules/apt/03clean' ]
    }
  }

  case $custom_preferences {
    false: {
      include apt::preferences::absent
    }
    default: {
      # When squeeze becomes the stable branch, transform this file's header
      # into a preferences.d file
      include apt::preferences
    }
  }

  include apt::dot_d_directories

  ## This package should really always be current
  package { 'debian-archive-keyring': ensure => latest }

  # backports uses the normal archive key now
  package { 'debian-backports-keyring': ensure => absent }

  if ($use_backports and !($::debian_release in ['testing', 'unstable', 'experimental'])) {
    apt::sources_list {
      'backports':
        content => "deb $backports_url ${::debian_codename}-backports ${apt::real_repos}",
    }
    if $include_src {
      apt::sources_list {
        'backports-src':
          content => "deb-src $backports_url ${::debian_codename}-backports ${apt::real_repos}",
      }
    }
  }

  include common::moduledir
  common::module_dir { 'apt': }
  $apt_base_dir = "${common::moduledir::module_dir_path}/apt"

  if $custom_key_dir {
    file { "${apt_base_dir}/keys.d":
      source  => $custom_key_dir,
      recurse => true,
      owner   => root,
      group   => root,
      mode    => '0755',
    }
    exec { 'custom_keys':
      command     => "find ${apt_base_dir}/keys.d -type f -exec apt-key add '{}' \\;",
      subscribe   => File["${apt_base_dir}/keys.d"],
      refreshonly => true,
      notify      => Exec[refresh_apt]
    }
    if $custom_preferences != false {
      Exec['custom_keys'] {
        before => File['apt_config']
      }
    }
  }

  # workaround for preseeded_package component
  file { [ '/var/cache', '/var/cache/local', '/var/cache/local/preseeding' ]: ensure => directory }

  exec { 'update_apt':
    command     => '/usr/bin/apt-get update',
    require     => [
      File['/etc/apt/apt.conf.d', '/etc/apt/preferences' ],
      File['/etc/apt/sources.list'] ],
    refreshonly => true,
    # Another Semaphor for all packages to reference
    alias       => [ 'apt_updated', 'refresh_apt']
  }

}
