# Usage
# git::changes { name:
#   cwd    =>  "/path/to/git/"
#   user   =>  "me",
#   ensure =>  {*assume-unchanged*, tracked}
# }
#

define git::changes ( $cwd, $user, $ensure='assume-unchanged' ) {

  case $ensure {
    default: { err ( "unknown ensure value '${ensure}'" ) }

    assume-unchanged: {
      exec { "assume-unchanged ${name}":
        command => "/usr/bin/git update-index --assume-unchanged ${name}",
        cwd     => $cwd,
        user    => $user,
        unless  => "/usr/bin/git ls-files -v | grep '^[ch] ${name}'",
      }
    }

    tracked: {
      exec { "track changes ${name}":
        command => "/usr/bin/git update-index --no-assume-unchanged ${name}",
        cwd     => $cwd,
        user    => $user,
        onlyif  => "/usr/bin/git ls-files -v | grep '^[ch] ${name}'",
      }
    }
  }
}

