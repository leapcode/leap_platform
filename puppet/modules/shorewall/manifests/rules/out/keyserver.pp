class shorewall::rules::out::keyserver {
  shorewall::rule {
    'me-net-tcp_keyserver':
      source          =>  '$FW',
      destination     =>  'net',
      proto           =>  'tcp',
      destinationport =>  '11371,11372',
      order           =>  240,
      action          => 'ACCEPT'; 
 }
}
