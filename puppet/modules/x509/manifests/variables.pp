class x509::variables {
  $root           = '/etc/x509'
  $certs          = "${root}/certs"
  $keys           = "${root}/keys"
  $x509_chain     = "${root}/certs"
  $local_CAs      = '/usr/local/share/ca-certificates'
}
