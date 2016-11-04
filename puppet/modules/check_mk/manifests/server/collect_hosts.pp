class check_mk::server::collect_hosts {
  Check_mk::Host <<| |>> {
    target => "${::check_mk::config::etc_dir}/check_mk/main.mk",
    notify => Exec['check_mk-refresh']
  }
}
