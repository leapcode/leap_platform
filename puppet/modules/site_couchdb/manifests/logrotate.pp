# configure couchdb logrotation
class site_couchdb::logrotate {

  augeas {
    'logrotate_bigcouch':
      context => '/files/etc/logrotate.d/bigcouch/rule',
      changes => [
        'set file /opt/bigcouch/var/log/*.log', 'set rotate 7',
        'set schedule daily', 'set compress compress',
        'set missingok missingok', 'set ifempty notifempty',
        'set copytruncate copytruncate' ]
  }

}
