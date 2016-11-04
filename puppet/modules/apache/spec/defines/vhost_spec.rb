require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost', :type => 'define' do
  let(:title){ 'example.com' }
  let(:facts){
    {
      :fqdn => 'apache.example.com',
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '7',
    }
  }
  let(:pre_condition) {
    'include apache'
  }
  describe 'with standard' do
    it { should contain_apache__vhost__template('example.com').with(
      :ensure         => 'present',
      :do_includes    => false,
      :run_mode       => 'normal',
      :ssl_mode       => false,
      :logmode        => 'default',
      :mod_security   => true,
      :htpasswd_file  => 'absent',
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    # go deeper in the catalog and the test the produced content from the template
    it { should contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None


  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with params' do
    let(:params){
      {
        :do_includes    => true,
        :ssl_mode       => true,
        :logmode        => 'anonym',
        :mod_security   => false,
        :htpasswd_file  => true,
      }
    }
    it { should contain_apache__vhost__template('example.com').with(
      :ensure                           => 'present',
      :path                             => 'absent',
      :path_is_webdir                   => false,
      :logpath                          => 'absent',
      :logmode                          => 'anonym',
      :logprefix                        => '',
      :domain                           => 'absent',
      :domainalias                      => 'absent',
      :server_admin                     => 'absent',
      :allow_override                   => 'None',
      :do_includes                      => true,
      :options                          => 'absent',
      :additional_options               => 'absent',
      :default_charset                  => 'absent',
      :php_settings                     => {},
      :php_options                      => {},
      :run_mode                         => 'normal',
      :run_uid                          => 'absent',
      :run_gid                          => 'absent',
      :template_partial                 => 'apache/vhosts/static/partial.erb',
      :ssl_mode                         => true,
      :htpasswd_file                    => true,
      :htpasswd_path                    => 'absent',
      :ldap_auth                        => false,
      :ldap_user                        => 'any',
      :mod_security                     => false,
      :mod_security_relevantonly        => true,
      :mod_security_rules_to_disable    => [],
      :mod_security_additional_options  => 'absent',
      :use_mod_macro                    => false,
      :passing_extension                => 'absent',
      :gempath                          => 'absent',
    )}
    # go deeper in the catalog and the test the produced content from the template
    it { should contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /var/www/vhosts/example.com/logs/access_log noip



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +Includes
    AuthType Basic
    AuthName \"Access fuer example.com\"
    AuthUserFile /var/www/htpasswds/example.com
    require valid-user

  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
<VirtualHost *:443 >

  Include include.d/defaults.inc
  Include include.d/ssl_defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /var/www/vhosts/example.com/logs/access_log noip



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride None
    Options  +Includes
    AuthType Basic
    AuthName \"Access fuer example.com\"
    AuthUserFile /var/www/htpasswds/example.com
    require valid-user

  </Directory>

  <IfModule mod_security2.c>
    SecRuleEngine Off
    SecAuditEngine Off
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with params II' do
    let(:params){
      {
        :vhost_mode     => 'file',
      }
    }
    it { should_not contain_apache__vhost__template('example.com') }
    it { should contain_apache__vhost__file('example.com').with(
      :ensure             => 'present',
      :vhost_source       => 'absent',
      :vhost_destination  => 'absent',
      :do_includes        => false,
      :run_mode       => 'normal',
      :mod_security   => true,
      :htpasswd_file  => 'absent',
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
  end
  describe 'with wrong vhost_mode' do
    let(:params){
      {
        :vhost_mode     => 'foo',
      }
    }
    it { expect { should compile }.to raise_error(Puppet::Error, /No such vhost_mode: foo defined for example.com\./)
    }
  end
end
