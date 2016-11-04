define couchdb::add_user ( $roles, $pw, $salt = '' ) {
  # Couchdb < 1.2 needs a pre-hashed pw and salt
  # If you provide a salt, couchdb::add_user will assume that
  # $pw is prehashed and pass both parameters to couchdb::update
  # If $salt is empty, couchdb::add_user will assume that the pw
  # is plaintext and will pass it to couchdb::update

  if $::couchdb::bigcouch == true {
    $port = 5986
  } else {
    $port = 5984
  }

  if $salt == '' {
    # unhashed, plaintext pw, no salt. For couchdb >= 1.2
    $data = "{\"type\": \"user\", \"name\": \"${name}\", \"roles\": ${roles}, \"password\": \"${pw}\"}"
  } else {
    # prehashed pw with salt, for couchdb < 1.2
    # salt and encrypt pw
    # str_and_salt2sha1 is a function from leap's stdlib module
    $pw_and_salt = [ $pw, $salt ]
    $sha         = str_and_salt2sha1($pw_and_salt)
    $data = "{\"type\": \"user\", \"name\": \"${name}\", \"roles\": ${roles}, \"password_sha\": \"${sha}\", \"salt\": \"${salt}\"}"
  }

  # update the user with the given password unless they already work
  couchdb::document { "update_user_${name}":
    host   => "127.0.0.1:${port}",
    db     => '_users',
    id     => "org.couchdb.user:${name}",
    data   => $data
  }

  couchdb::query::setup { $name:
    user  => $name,
    pw    => $pw,
  }

}
