# manifests/svn.pp

class git::svn {
  include ::git
  include subversion

  package { 'git-svn':
    require => [ Package['git'], Package['subversion'] ],
  }
}
