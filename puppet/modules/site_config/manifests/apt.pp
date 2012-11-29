class site_config::apt {

  include ::apt

  apt::apt_conf { '90disable-pdiffs':
    content => 'Acquire::PDiffs "false";';
  }
}
