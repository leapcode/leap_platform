class apache::include::mod_fcgid {
  apache::config::global{'mod_fcgid.conf':
    content => "<IfModule mod_fcgid.c>
  FcgidFixPathinfo 1
</IfModule>\n"
  }
}
