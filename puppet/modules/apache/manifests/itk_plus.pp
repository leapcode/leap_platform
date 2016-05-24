# manifests/itk.pp
#
# see: http://mpm-itk.sesse.net/

class apache::itk_plus inherits apache::itk {
    case $::operatingsystem {
        centos: { include ::apache::centos::itk_plus }
        default: { fail("itk plus mode is currently only implemented for CentOS") }
    }
}
