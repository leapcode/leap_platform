class apache::noiplog {
  apache::config::global{ 'noip_log.conf':
    content => 'LogFormat "127.0.0.1 - - %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %T %V" noip';
  }
}
