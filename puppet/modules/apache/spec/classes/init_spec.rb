require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))

describe 'apache', :type => 'class' do
  describe 'with standard' do
    #puppet-rspec bug
    #it { should compile.with_all_deps }

    it { should contain_class('apache::base') }
    it { should_not contain_class('apache::status') }
    it { should_not contain_class('shorewall::rules::http') }
    it { should_not contain_class('apache::ssl') }
    context 'on centos' do
      let(:facts) {
        {
          :operatingsystem => 'CentOS',
        }
      }
      it { should contain_class('apache::centos') }
    end
  end
  describe 'with params' do
    let(:facts) {
      {
        :concat_basedir => '/var/lib/puppet/concat'
      }
    }
    let(:params){
      {
        :manage_shorewall => true,
        # there is puppet-librarian bug in using that module
        #:manage_munin     => true,
        :ssl              => true,
      }
    }
    #puppet-rspec bug
    #it { should compile.with_all_deps }

    it { should contain_class('apache::base') }
    it { should_not contain_class('apache::status') }
    it { should contain_class('shorewall::rules::http') }
    it { should contain_class('apache::ssl') }
  end
end
