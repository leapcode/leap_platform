class apache::ssl::itk_plus::centos inherits apache::ssl::centos {
  include apache::ssl::itk::centos
  Apache::Config::Global['ssl.conf']{
    source => "modules/apache/itk_plus/conf.d/${::operatingsystem}/ssl.conf",
  }

  Apache::Config::Global['00-listen-ssl.conf']{
    ensure => 'present',
    content => template("apache/itk_plus/${::operatingsystem}/00-listen-ssl.conf.erb"),
  }
}
