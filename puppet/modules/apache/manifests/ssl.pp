# manifests/ssl.pp

class apache::ssl {
  case $::operatingsystem {
    centos: { include apache::ssl::centos }
    openbsd: { include apache::ssl::openbsd }
    debian: { include apache::ssl::debian }
    defaults: { include apache::ssl::base }
  }
  if $apache::manage_shorewall {
    include shorewall::rules::https
  }
}
