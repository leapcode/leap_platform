class site_couchdb::apache_ssl_proxy {

# This is here to disable the previously configured apache ssl proxy
# we were using this, but have switched to stunnel instead.
#
# Unfortunately, the current apache shared module doesn't handle
# ensure=>absent, so this is going to be done the crude way, and will only
# work for debian+derivitives, which is fine for now, but not good for the
# future

  package { 'apache2': ensure => absent }

}
