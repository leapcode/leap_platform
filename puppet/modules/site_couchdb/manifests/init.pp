class site_config::couchdb {
  apt::sources_list { "unstable.list":
    source => [ "puppet:///modules/site_apt/unstable.list"],
  }

}
