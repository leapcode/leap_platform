define check_mk::agent::install_local($source=undef, $content=undef, $ensure='present') {
  @file { "/usr/lib/check_mk_agent/local/${name}" :
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $content,
    source  => $source,
    tag     => 'check_mk::local',
    require => Package['check-mk-agent'],
  }
}
