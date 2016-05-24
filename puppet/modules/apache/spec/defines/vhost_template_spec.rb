require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::template', :type => 'define' do
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
    it { should contain_apache__vhost__file('example.com').with(
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
    it { should contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => true,
      :run_mode       => 'normal',
      :ssl_mode       => true,
      :logmode        => 'anonym',
      :mod_security   => false,
      :htpasswd_file  => true,
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
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
        :do_includes    => true,
        :ssl_mode       => 'force',
        :logmode        => 'semianonym',
        :mod_security   => false,
        :htpasswd_file  => true,
      }
    }
    it { should contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => true,
      :run_mode       => 'normal',
      :ssl_mode       => 'force',
      :logmode        => 'semianonym',
      :mod_security   => false,
      :htpasswd_file  => true,
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { should contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log noip



  RewriteEngine On
  RewriteCond %{HTTPS} !=on
  RewriteCond %{HTTP:X-Forwarded-Proto} !=https
  RewriteRule (.*) https://%{SERVER_NAME}$1 [R=permanent,L]
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


  ErrorLog /var/www/vhosts/example.com/logs/error_log
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
  describe 'with params III' do
    let(:params){
      {
        :do_includes    => false,
        :ssl_mode       => 'only',
        :logmode        => 'nologs',
        :mod_security   => true,
        :htpasswd_file  => 'absent',
      }
    }
    it { should contain_apache__vhost__file('example.com').with(
      :ensure         => 'present',
      :do_includes    => false,
      :run_mode       => 'normal',
      :ssl_mode       => 'only',
      :logmode        => 'nologs',
      :mod_security   => true,
      :htpasswd_file  => 'absent',
      :htpasswd_path  => 'absent',
      :use_mod_macro  => false,
    )}
    it { should contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:443 >

  Include include.d/defaults.inc
  Include include.d/ssl_defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/


  ErrorLog /dev/null
  CustomLog /dev/null



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
end
