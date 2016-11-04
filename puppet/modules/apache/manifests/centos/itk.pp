# http://hostby.net/home/2008/07/12/centos-5-and-mpm-itk/
class apache::centos::itk inherits apache::centos {
    include ::apache::base::itk
    Package['apache']{
        name => 'httpd-itk',
    }
    File['apache_service_config']{
      source => "puppet:///modules/apache/service/${::operatingsystem}/httpd.itk"
    }
}
