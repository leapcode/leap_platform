# manifests/itk.pp
#
# see: http://mpm-itk.sesse.net/

class apache::itk inherits apache {
    case $::operatingsystem {
        centos: { include ::apache::centos::itk }
        debian: { include ::apache::debian::itk }
        default: { include ::apache::base::itk }
    }
}
