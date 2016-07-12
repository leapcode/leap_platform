class apache::ssl::itk_plus inherits apache::ssl::itk {
    case $::operatingsystem {
        centos: { include ::apache::ssl::itk_plus::centos }
        default: { fail("itk plus mode is currently only implemented for CentOS") }
    }
}
