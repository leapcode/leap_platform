define site_couchdb::upload_design($db = $title, $design) {
  $design_name = regsubst($design, '^.*\/(.*)\.json$', '\1')
  $id = "_design/${design_name}"
  $file = "/srv/leap/couchdb/designs/${design}"
  exec {
    "upload_design_${name}":
      command => "/usr/local/bin/couch-doc-update --host 127.0.0.1:5984 --db '${db}' --id '${id}' --data '{}' --file '${file}'",
      refreshonly => false,
      loglevel => debug,
      logoutput => on_failure,
      require => File['/srv/leap/couchdb/designs'];
  }
}
