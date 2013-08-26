# Usage
# git::changes { name:
#   user   =>  "me",
#   ensure =>  {*assume-unchanged*, tracked}
# }
#

define git::changes ( $user, $ensure='assume-unchanged' ) {

  case $ensure {
    default: { err ( "unknown ensure value '${ensure}'" ) }

    assume-unchanged: {
      exec { "assume-unchanged ${name}":
        command => "/usr/bin/git update-index --assume-unchanged ${name}",
        user    => $user,
        unless  => "/usr/bin/git ls-files -v | grep '^[ch] ${name}'",
      }
    }
    
    tracked: {
      exec { "assume-unchanged ${name}":
        command => "/usr/bin/git update-index --no-assume-unchanged ${name}",
        user    => $user,
        onlyif  => "/usr/bin/git ls-files -v | grep '^[ch] ${name}'",
      }
    }
  }
}

