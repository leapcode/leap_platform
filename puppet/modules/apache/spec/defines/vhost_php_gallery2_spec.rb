require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::php::gallery2', :type => 'define' do
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
      :manage_directories             => true,
      :template_partial               => 'apache/vhosts/php_gallery2/partial.erb',
      :php_settings                   => {
        'safe_mode'         => 'Off',
        'output_buffering'  => 'Off',
      },
      :manage_config                  => true,
      :config_webwriteable            => false,
      :config_file                    => 'config.php',
    )}
    it { should contain_file('/var/www/vhosts/example.com/data/upload').with(
      :ensure => 'directory',
      :owner  => 'apache',
      :group  => 0,
      :mode   => '0660',
    )}
    it { should contain_file('/var/www/vhosts/example.com/data/gdata').with(
      :ensure => 'directory',
      :owner  => 'apache',
      :group  => 0,
      :mode   => '0660',
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
    AllowOverride None

    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com
    php_admin_flag output_buffering off
    php_admin_flag safe_mode off
    php_admin_value session.save_path /var/www/session.save_path/example.com
    php_admin_value upload_tmp_dir /var/www/upload_tmp_dir/example.com



    # Always rewrite login's
    # Source: http://gallery.menalto.com/node/30558
    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteCond %{HTTP:X-Forwarded-Proto} !=https
    RewriteCond %{HTTP_COOKIE} ^GALLERYSID= [OR]
    RewriteCond %{QUERY_STRING} subView=core\\.UserLogin
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [NE,R,L]
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
      :template_partial               => 'apache/vhosts/php_gallery2/partial.erb',
      :php_settings                   => {
        'safe_mode'         => 'Off',
        'output_buffering'  => 'Off',
      },
      :manage_directories             => true,
      :manage_config                  => true,
      :config_webwriteable            => false,
      :config_file                    => 'config.php',
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
    AllowOverride None
    Options  +ExecCGI



    # Always rewrite login's
    # Source: http://gallery.menalto.com/node/30558
    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteCond %{HTTP:X-Forwarded-Proto} !=https
    RewriteCond %{HTTP_COOKIE} ^GALLERYSID= [OR]
    RewriteCond %{QUERY_STRING} subView=core\\.UserLogin
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [NE,R,L]
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
end
