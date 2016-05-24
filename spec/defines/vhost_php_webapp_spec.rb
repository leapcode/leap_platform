require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::php::webapp', :type => 'define' do
  let(:title){ 'example.com' }
  let(:facts){
    {
      :fqdn => 'apache.example.com',
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '7',
    }
  }
  describe 'with standard' do
    let(:params){
      {
        :manage_config    => false,
        :template_partial => 'apache/vhosts/php/partial.erb',
      }
    }
    # only test variables that are tuned
    it { should have_apache__file__rw_resource_count(0) }
    it { should_not contain_apache__vhost__file__documentrootfile('configurationfile_example.com') }
    it { should contain_apache__vhost__php__standard('example.com') }
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
    AllowOverride None

    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com
    php_admin_flag safe_mode on
    php_admin_value session.save_path /var/www/session.save_path/example.com
    php_admin_value upload_tmp_dir /var/www/upload_tmp_dir/example.com


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
  describe 'with mod_fcgid' do
    let(:params){
      {
        :manage_config    => false,
        :template_partial => 'apache/vhosts/php/partial.erb',
        :run_mode => 'fcgid',
        :run_uid  => 'foo',
        :run_gid  => 'bar',
      }
    }
    # only test variables that are tuned
    it { should have_apache__file__rw_resource_count(0) }
    it { should_not contain_apache__vhost__file__documentrootfile('configurationfile_example.com') }
    it { should contain_apache__vhost__php__standard('example.com') }
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
    AllowOverride None
    Options  +ExecCGI


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
  context 'with config file and directories' do
    describe 'with standard' do
      let(:params){
        {
          :manage_config        => true,
          :managed_directories  => [ '/tmp/a', '/tmp/b' ],
          :config_file          => 'config.php',
          :template_partial     => 'apache/vhosts/php/partial.erb',
        }
      }
      # only test variables that are tuned
      it { should have_apache__file__rw_resource_count(2) }
      it { should contain_apache__file__rw('/tmp/a').with(
        :owner => 'apache',
        :group => 0,
      )}
      it { should contain_apache__file__rw('/tmp/b').with(
        :owner => 'apache',
        :group => 0,
      )}
      it { should contain_apache__vhost__file__documentrootfile('configurationfile_example.com').with(
        :documentroot => '/var/www/vhosts/example.com/www',
        :filename     => 'config.php',
        :thedomain    => 'example.com',
        :owner        => 'apache',
        :group        => 0,
        :mode         => '0440',
      ) }
      it { should contain_apache__vhost__php__standard('example.com') }
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
    AllowOverride None

    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com
    php_admin_flag safe_mode on
    php_admin_value session.save_path /var/www/session.save_path/example.com
    php_admin_value upload_tmp_dir /var/www/upload_tmp_dir/example.com


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
    describe 'with standard but writable' do
      let(:params){
        {
          :manage_config        => true,
          :config_webwriteable  => true,
          :managed_directories  => [ '/tmp/a', '/tmp/b' ],
          :config_file          => 'config.php',
          :template_partial     => 'apache/vhosts/php/partial.erb',
        }
      }
      # only test variables that are tuned
      it { should have_apache__file__rw_resource_count(2) }
      it { should contain_apache__file__rw('/tmp/a').with(
        :owner => 'apache',
        :group => 0,
      )}
      it { should contain_apache__file__rw('/tmp/b').with(
        :owner => 'apache',
        :group => 0,
      )}
      it { should contain_apache__vhost__file__documentrootfile('configurationfile_example.com').with(
        :documentroot => '/var/www/vhosts/example.com/www',
        :filename     => 'config.php',
        :thedomain    => 'example.com',
        :owner        => 'apache',
        :group        => 0,
        :mode         => '0660',
      ) }
      it { should contain_apache__vhost__php__standard('example.com') }
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
    AllowOverride None

    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com
    php_admin_flag safe_mode on
    php_admin_value session.save_path /var/www/session.save_path/example.com
    php_admin_value upload_tmp_dir /var/www/upload_tmp_dir/example.com


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
end
