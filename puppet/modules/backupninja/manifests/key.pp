# generate and deploy backupninja sshkeys
define backupninja::key(
  $user = $name,
  $createkey = false,
  $keymanage = $backupninja::keymanage,
  $keyowner = $backupninja::keyowner,
  $keygroup = $backupninja::keygroup,
  $keystore= $backupninja::keystore,
  $keystorefspath = $backupninja::keystorefspath,
  $keytype = $backupninja::keytype,
  $keydest = $backupninja::keydest,
  $keydestname = "id_${backupninja::keytype}" )
{

  # generate the key
  if $createkey == true {
    if $keystorefspath == false {
      err('need to define a destination directory for sshkey creation!')
    }
    $ssh_keys = ssh_keygen("${keystorefspath}/${keydestname}")
  }

  # deploy/manage the key
  if $keymanage == true {
    $keydestfile = "${keydest}/${keydestname}"
    ensure_resource('file', $keydest, {
      'ensure' => 'directory',
      'mode'   => '0700',
      'owner'  => $keyowner,
      'group'  => $keygroup
    })
    ensure_resource('file', $keydestfile, {
      'ensure'  => 'present',
      'source'  => "${keystore}/${user}_id_${keytype}",
      'mode'    => '0700',
      'owner'   => $keyowner,
      'group'   => $keygroup,
      'require' => File[$keydest],
    })
  }
}
