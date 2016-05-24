require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::php::wordpress', :type => 'define' do
  let(:title){ 'example.com' }
  let(:facts){
    {
      :fqdn => 'apache.example.com',
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '7',
    }
  }
  describe 'with standard' do
    # only test the differences from the default
    it { should contain_apache__vhost__php__webapp('example.com').with(
      :mod_security_rules_to_disable  => ["960010", "950018"],
      :manage_directories             => true,
      :managed_directories            => '/var/www/vhosts/example.com/www/wp-content',
      :template_partial               => 'apache/vhosts/php_wordpress/partial.erb',
      :manage_config                  => true,
      :config_webwriteable            => false,
      :config_file                    => 'wp-config.php',
    )}
    # go deeper in the catalog and test the produced template
    it { should contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/
  DirectoryIndex index.htm index.html index.php


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride FileInfo

    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com
    php_admin_flag safe_mode on
    php_admin_value session.save_path /var/www/session.save_path/example.com
    php_admin_value upload_tmp_dir /var/www/upload_tmp_dir/example.com


  </Directory>


  # fixes: http://git.zx2c4.com/w3-total-fail/tree/w3-total-fail.sh
  <Directory \"/var/www/vhosts/example.com/www/wp-content/w3tc/dbcache\">
    Deny From All
  </Directory>

  # simple wp-login brute force protection
  # http://www.frameloss.org/2013/04/26/even-easier-brute-force-login-protection-for-wordpress/
  RewriteEngine On
  RewriteCond %{HTTP_COOKIE} !359422a82c97336dc082622faf72013a8e857bfd
  RewriteRule ^/wp-login.php /wordpress-login-576a63fdc98202e7c7283713f2ddfee334bf13ee.php [R,L]
  <Location /wordpress-login-576a63fdc98202e7c7283713f2ddfee334bf13ee.php>
    CookieTracking on
    CookieExpires 30
    CookieName 359422a82c97336dc082622faf72013a8e857bfd
  </Location>
  RewriteRule ^/wordpress-login-576a63fdc98202e7c7283713f2ddfee334bf13ee.php /wp-login.php [NE]


  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log

    SecRuleRemoveById \"960010\"
    SecRuleRemoveById \"950018\"
  </IfModule>

</VirtualHost>
"
)}
  end
  describe 'with mod_fcgid' do
    let(:params){
      {
        :run_mode => 'fcgid',
        :run_uid  => 'foo',
        :run_gid  => 'bar',
      }
    }
    # only test variables that are tuned
    it { should contain_apache__vhost__php__webapp('example.com').with(
      :run_mode                       => 'fcgid',
      :run_uid                        => 'foo',
      :run_gid                        => 'bar',
      :template_partial               => 'apache/vhosts/php_wordpress/partial.erb',
      :mod_security_rules_to_disable  => ["960010", "950018"],
      :manage_directories             => true,
      :managed_directories            => '/var/www/vhosts/example.com/www/wp-content',
      :manage_config                  => true,
      :config_webwriteable            => false,
      :config_file                    => 'wp-config.php',
    )}
    # go deeper in the catalog and test the produced template
    it { should contain_apache__vhost__file('example.com').with_content(
"<VirtualHost *:80 >

  Include include.d/defaults.inc
  ServerName example.com
  DocumentRoot /var/www/vhosts/example.com/www/
  DirectoryIndex index.htm index.html index.php


  ErrorLog /var/www/vhosts/example.com/logs/error_log
  CustomLog /var/www/vhosts/example.com/logs/access_log combined



  <IfModule mod_fcgid.c>
    SuexecUserGroup foo bar
    FcgidMaxRequestsPerProcess 5000
    FCGIWrapper /var/www/mod_fcgid-starters/example.com/example.com-starter .php
    AddHandler fcgid-script .php
  </IfModule>

  <Directory \"/var/www/vhosts/example.com/www/\">
    AllowOverride FileInfo
    Options  +ExecCGI


  </Directory>


  # fixes: http://git.zx2c4.com/w3-total-fail/tree/w3-total-fail.sh
  <Directory \"/var/www/vhosts/example.com/www/wp-content/w3tc/dbcache\">
    Deny From All
  </Directory>

  # simple wp-login brute force protection
  # http://www.frameloss.org/2013/04/26/even-easier-brute-force-login-protection-for-wordpress/
  RewriteEngine On
  RewriteCond %{HTTP_COOKIE} !359422a82c97336dc082622faf72013a8e857bfd
  RewriteRule ^/wp-login.php /wordpress-login-576a63fdc98202e7c7283713f2ddfee334bf13ee.php [R,L]
  <Location /wordpress-login-576a63fdc98202e7c7283713f2ddfee334bf13ee.php>
    CookieTracking on
    CookieExpires 30
    CookieName 359422a82c97336dc082622faf72013a8e857bfd
  </Location>
  RewriteRule ^/wordpress-login-576a63fdc98202e7c7283713f2ddfee334bf13ee.php /wp-login.php [NE]


  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log

    SecRuleRemoveById \"960010\"
    SecRuleRemoveById \"950018\"
  </IfModule>

</VirtualHost>
"
)}
  end
end
