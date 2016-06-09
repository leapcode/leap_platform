class git::web::lighttpd {
  include ::lighttpd 

  lighttpd::config::file{'lighttpd-gitweb':
    content => 'global { server.modules += ("mod_rewrite", "mod_redirect", "mod_alias", "mod_setenv", "mod_cgi" ) }',
  }
}
