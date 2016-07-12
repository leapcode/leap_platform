require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::php::joomla', :type => 'define' do
  let(:title){ 'example.com' }
  let(:facts){
    {
      :fqdn => 'apache.example.com',
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '7',
    }
  }
  describe 'with standard' do
    it { should contain_class('apache::include::joomla') }
    # only test the differences from the default
    it { should contain_apache__vhost__php__webapp('example.com').with(
      :template_partial               => 'apache/vhosts/php_joomla/partial.erb',
      :php_settings                   => {
        'allow_url_fopen'   => 'on',
        'allow_url_include' => 'off',
      },
      :manage_config                  => true,
      :config_webwriteable            => false,
      :config_file                    => 'configuration.php',
      :manage_directories             => true,
      :managed_directories            =>  [ "/var/www/vhosts/example.com/www/administrator/backups",
                                            "/var/www/vhosts/example.com/www/administrator/components",
                                            "/var/www/vhosts/example.com/www/administrator/language",
                                            "/var/www/vhosts/example.com/www/administrator/modules",
                                            "/var/www/vhosts/example.com/www/administrator/templates",
                                            "/var/www/vhosts/example.com/www/components",
                                            "/var/www/vhosts/example.com/www/dmdocuments",
                                            "/var/www/vhosts/example.com/www/images",
                                            "/var/www/vhosts/example.com/www/language",
                                            "/var/www/vhosts/example.com/www/media",
                                            "/var/www/vhosts/example.com/www/modules",
                                            "/var/www/vhosts/example.com/www/plugins",
                                            "/var/www/vhosts/example.com/www/templates",
                                            "/var/www/vhosts/example.com/www/cache",
                                            "/var/www/vhosts/example.com/www/tmp",
                                            "/var/www/vhosts/example.com/www/administrator/cache" ],
      :mod_security_additional_options => "
    # http://optics.csufresno.edu/~kriehn/fedora/fedora_files/f9/howto/modsecurity.html
    # Exceptions for Joomla Root Directory
    <LocationMatch \"^/\">
        SecRuleRemoveById 950013
    </LocationMatch>

    # Exceptions for Joomla Administration Panel
    SecRule REQUEST_FILENAME \"/administrator/index2.php\" \"id:1199400,allow,phase:1,nolog,ctl:ruleEngine=Off\"

    # Exceptions for Joomla Component Expose
    <LocationMatch \"^/components/com_expose/expose/manager/amfphp/gateway.php\">
        SecRuleRemoveById 960010
    </LocationMatch>
"
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

    php_admin_flag allow_url_fopen on
    php_admin_flag allow_url_include off
    php_admin_flag engine on
    php_admin_value error_log /var/www/vhosts/example.com/logs/php_error_log
    php_admin_value open_basedir /var/www/vhosts/example.com/www:/var/www/vhosts/example.com/data:/var/www/upload_tmp_dir/example.com:/var/www/session.save_path/example.com
    php_admin_flag safe_mode on
    php_admin_value session.save_path /var/www/session.save_path/example.com
    php_admin_value upload_tmp_dir /var/www/upload_tmp_dir/example.com
 


    Include include.d/joomla.inc
  </Directory>

  <Directory \"/var/www/vhosts/example.com/www/administrator/\">
    RewriteEngine on

    # Rewrite URLs to https that go for the admin area
    RewriteCond %{REMOTE_ADDR} !^127\\.[0-9]+\\.[0-9]+\\.[0-9]+$
    RewriteCond %{HTTPS} !=on
    RewriteCond %{REQUEST_URI} (.*/administrator/.*)
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R]
  </Directory>

  # Deny various directories that
  # shouldn't be webaccessible
  <Directory \"/var/www/vhosts/example.com/www/tmp/\">
    Deny From All
  </Directory>
  <Directory \"/var/www/vhosts/example.com/www/logs/\">
    Deny From All
  </Directory>
  <Directory \"/var/www/vhosts/example.com/www/cli/\">
    Deny From All
  </Directory>


  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log

    
    # http://optics.csufresno.edu/~kriehn/fedora/fedora_files/f9/howto/modsecurity.html
    # Exceptions for Joomla Root Directory
    <LocationMatch \"^/\">
        SecRuleRemoveById 950013
    </LocationMatch>

    # Exceptions for Joomla Administration Panel
    SecRule REQUEST_FILENAME \"/administrator/index2.php\" \"id:1199400,allow,phase:1,nolog,ctl:ruleEngine=Off\"

    # Exceptions for Joomla Component Expose
    <LocationMatch \"^/components/com_expose/expose/manager/amfphp/gateway.php\">
        SecRuleRemoveById 960010
    </LocationMatch>

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
    it { should contain_class('apache::include::joomla') }
    # only test the differences from the default
    it { should contain_apache__vhost__php__webapp('example.com').with(
      :run_mode                       => 'fcgid',
      :run_uid                        => 'foo',
      :run_gid                        => 'bar',
      :template_partial               => 'apache/vhosts/php_joomla/partial.erb',
      :php_settings                   => {
        'allow_url_fopen'   => 'on',
        'allow_url_include' => 'off',
      },
      :manage_config                  => true,
      :config_webwriteable            => false,
      :config_file                    => 'configuration.php',
      :manage_directories             => true,
      :managed_directories            =>  [ "/var/www/vhosts/example.com/www/administrator/backups",
                                            "/var/www/vhosts/example.com/www/administrator/components",
                                            "/var/www/vhosts/example.com/www/administrator/language",
                                            "/var/www/vhosts/example.com/www/administrator/modules",
                                            "/var/www/vhosts/example.com/www/administrator/templates",
                                            "/var/www/vhosts/example.com/www/components",
                                            "/var/www/vhosts/example.com/www/dmdocuments",
                                            "/var/www/vhosts/example.com/www/images",
                                            "/var/www/vhosts/example.com/www/language",
                                            "/var/www/vhosts/example.com/www/media",
                                            "/var/www/vhosts/example.com/www/modules",
                                            "/var/www/vhosts/example.com/www/plugins",
                                            "/var/www/vhosts/example.com/www/templates",
                                            "/var/www/vhosts/example.com/www/cache",
                                            "/var/www/vhosts/example.com/www/tmp",
                                            "/var/www/vhosts/example.com/www/administrator/cache" ],
      :mod_security_additional_options => "
    # http://optics.csufresno.edu/~kriehn/fedora/fedora_files/f9/howto/modsecurity.html
    # Exceptions for Joomla Root Directory
    <LocationMatch \"^/\">
        SecRuleRemoveById 950013
    </LocationMatch>

    # Exceptions for Joomla Administration Panel
    SecRule REQUEST_FILENAME \"/administrator/index2.php\" \"id:1199400,allow,phase:1,nolog,ctl:ruleEngine=Off\"

    # Exceptions for Joomla Component Expose
    <LocationMatch \"^/components/com_expose/expose/manager/amfphp/gateway.php\">
        SecRuleRemoveById 960010
    </LocationMatch>
"
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
 


    Include include.d/joomla.inc
  </Directory>

  <Directory \"/var/www/vhosts/example.com/www/administrator/\">
    RewriteEngine on

    # Rewrite URLs to https that go for the admin area
    RewriteCond %{REMOTE_ADDR} !^127\\.[0-9]+\\.[0-9]+\\.[0-9]+$
    RewriteCond %{HTTPS} !=on
    RewriteCond %{REQUEST_URI} (.*/administrator/.*)
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R]
  </Directory>

  # Deny various directories that
  # shouldn't be webaccessible
  <Directory \"/var/www/vhosts/example.com/www/tmp/\">
    Deny From All
  </Directory>
  <Directory \"/var/www/vhosts/example.com/www/logs/\">
    Deny From All
  </Directory>
  <Directory \"/var/www/vhosts/example.com/www/cli/\">
    Deny From All
  </Directory>


  <IfModule mod_security2.c>
    SecRuleEngine On
    SecAuditEngine RelevantOnly
    SecAuditLogType Concurrent
    SecAuditLogStorageDir /var/www/vhosts/example.com/logs/
    SecAuditLog /var/www/vhosts/example.com/logs/mod_security_audit.log
    SecDebugLog /var/www/vhosts/example.com/logs/mod_security_debug.log

    
    # http://optics.csufresno.edu/~kriehn/fedora/fedora_files/f9/howto/modsecurity.html
    # Exceptions for Joomla Root Directory
    <LocationMatch \"^/\">
        SecRuleRemoveById 950013
    </LocationMatch>

    # Exceptions for Joomla Administration Panel
    SecRule REQUEST_FILENAME \"/administrator/index2.php\" \"id:1199400,allow,phase:1,nolog,ctl:ruleEngine=Off\"

    # Exceptions for Joomla Component Expose
    <LocationMatch \"^/components/com_expose/expose/manager/amfphp/gateway.php\">
        SecRuleRemoveById 960010
    </LocationMatch>

  </IfModule>

</VirtualHost>
"
)}
  end
end
