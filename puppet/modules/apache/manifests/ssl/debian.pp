class apache::ssl::debian inherits apache::ssl::base {
    apache::debian::module { 'ssl': ensure => present }
    apache::config::global { 'ssl.conf': }
}
