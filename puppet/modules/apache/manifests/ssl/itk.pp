# manifests/ssl/itk.pp

class apache::ssl::itk inherits apache::ssl {
    case $::operatingsystem {
        centos: { include apache::ssl::itk::centos }
    }
}

