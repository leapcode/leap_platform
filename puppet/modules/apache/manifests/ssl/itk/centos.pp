class apache::ssl::itk::centos inherits apache::ssl::centos {
    Package['mod_ssl']{
        name => 'mod_ssl-itk',
    }
}

