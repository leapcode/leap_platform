# configure debian unstable aka "sid"
# currently only used for installations that
# use plain couchdb instead of bigcouch
class site_apt::sid_repo {

  apt::sources_list { 'debian_sid.list':
    content => "deb http://httpredir.debian.org/debian/ sid main\n",
    before  => Exec[refresh_apt]
  }

}
