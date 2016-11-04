require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache::vhost::file', :type => 'define' do
  let(:title){ 'example.com' }
  let(:facts){
    {
      :fqdn => 'apache.example.com',
    }
  }
  let(:pre_condition) {
    'include apache'
  }
  describe 'with standard' do
    it { should contain_file('example.com.conf').with(
      :ensure  => 'present',
      :source  => [ "puppet:///modules/site_apache/vhosts.d/apache.example.com/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d//example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/./example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d//example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/./example.com.conf",
                  "puppet:///modules/apache/vhosts.d//example.com.conf",
                  "puppet:///modules/apache/vhosts.d/example.com.conf" ],
      :path    => '/etc/apache2/vhosts.d/example.com.conf',
      :require => 'File[vhosts_dir]',
      :notify  => 'Service[apache]',
      :owner   => 'root',
      :group   => 0,
      :mode    => '0644',
    )}
    it { should_not contain_file('/var/www/htpasswds/example.com') }
    it { should_not contain_class('apache::includes') }
    it { should_not contain_class('apache::mod_macro') }
    it { should_not contain_class('apache::noiplog') }
    it { should_not contain_class('apache::itk::lock') }
    it { should_not contain_class('mod_security::itk_plus') }
    it { should_not contain_class('mod_security') }
  end
  context 'on centos' do
    let(:facts){
      {
        :fqdn                       => 'apache.example.com',
        :operatingsystem            => 'CentOS',
        :operatingsystemmajrelease  => '7',
      }
    }
    it { should contain_file('example.com.conf').with(
      :ensure  => 'present',
      :source  => [ "puppet:///modules/site_apache/vhosts.d/apache.example.com/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d//example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/CentOS.7/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/CentOS/example.com.conf",
                  "puppet:///modules/site_apache/vhosts.d/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/CentOS.7/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/CentOS/example.com.conf",
                  "puppet:///modules/apache/vhosts.d/example.com.conf" ],
      :path    => '/etc/httpd/vhosts.d/example.com.conf',
      :require => 'File[vhosts_dir]',
      :notify  => 'Service[apache]',
      :owner   => 'root',
      :group   => 0,
      :mode    => '0644',
    )}
    it { should_not contain_file('/var/www/htpasswds/example.com') }
    it { should_not contain_class('apache::includes') }
    it { should_not contain_class('apache::mod_macro') }
    it { should_not contain_class('apache::noiplog') }
    it { should_not contain_class('apache::itk::lock') }
    it { should_not contain_class('mod_security::itk_plus') }
    it { should_not contain_class('mod_security') }
    context 'with params' do
      let(:params) {
        {
          :vhost_destination => '/tmp/a/example.com.conf',
          :vhost_source      => 'modules/my_module/example.com.conf',
          :htpasswd_file     => true,
          :do_includes       => true,
          :mod_security      => true,
          :use_mod_macro     => true,
          :logmode           => 'anonym',
        }
      }
      it { should contain_file('example.com.conf').with(
        :ensure  => 'present',
        :source  => 'puppet:///modules/my_module/example.com.conf',
        :path    => '/tmp/a/example.com.conf',
        :require => 'File[vhosts_dir]',
        :notify  => 'Service[apache]',
        :owner   => 'root',
        :group   => 0,
        :mode    => '0644',
      )}
      it { should contain_file('/var/www/htpasswds/example.com').with(
        :source  => [ "puppet:///modules/site_apache/htpasswds/apache.example.com/example.com",
                      "puppet:///modules/site_apache/htpasswds//example.com",
                      "puppet:///modules/site_apache/htpasswds/example.com" ],
        :owner   => 'root',
        :group   => 0,
        :mode    => '0644',
      )}
      it { should contain_class('apache::includes') }
      it { should contain_class('apache::mod_macro') }
      it { should contain_class('apache::noiplog') }
      it { should_not contain_class('apache::itk::lock') }
      it { should_not contain_class('mod_security::itk_plus') }
      it { should contain_class('mod_security') }
    end
    context 'with content' do
      let(:params) {
        {
          :content => "<VirtualHost *:80>\n  Servername example.com\n</VirtualHost>"
        }
      }
      it { should contain_file('example.com.conf').with(
        :ensure  => 'present',
        :path    => '/etc/httpd/vhosts.d/example.com.conf',
        :require => 'File[vhosts_dir]',
        :notify  => 'Service[apache]',
        :owner   => 'root',
        :group   => 0,
        :mode    => '0644',
      )}
      it { should contain_file('example.com.conf').with_content(
"<VirtualHost *:80>
  Servername example.com
</VirtualHost>"
      )}
      it { should_not contain_file('/var/www/htpasswds/example.com') }
    end
  end
end
