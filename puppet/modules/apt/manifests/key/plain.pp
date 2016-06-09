define apt::key::plain ($source) {
  file {
    "${apt::apt_base_dir}/keys/${name}":
      source  => $source;
    "${apt::apt_base_dir}/keys":
      ensure  => directory;
  }
  exec { "apt-key add '${apt::apt_base_dir}/keys/${name}'":
    subscribe   => File["${apt::apt_base_dir}/keys/${name}"],
    refreshonly => true,
    notify      => Exec['apt_updated'],
  }
}
