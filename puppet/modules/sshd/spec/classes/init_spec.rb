require 'spec_helper'

describe 'sshd' do

  shared_examples "a Linux OS" do
    it { should compile.with_all_deps }
    it { should contain_class('sshd') }
    it { should contain_class('sshd::client') }

    it { should contain_service('sshd').with({
      :ensure     => 'running',
      :enable     => true,
      :hasstatus  => true
    })}

    it { should contain_file('sshd_config').with(
      {
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => '0',
        'mode'    => '0600',
      }
    )}

    context 'change ssh port' do
      let(:params){{
       :ports => [ 22222],
      }}
      it { should contain_file(
          'sshd_config'
      ).with_content(/Port 22222/)}
    end
  end

  context "Debian OS" do
    let :facts do
      {
        :operatingsystem => 'Debian',
        :osfamily        => 'Debian',
        :lsbdistcodename => 'wheezy',
      }
    end
    it_behaves_like "a Linux OS"
    it { should contain_package('openssh') }
    it { should contain_class('sshd::debian') }
    it { should contain_service('sshd').with(
      :hasrestart => true
    )}

    context "Ubuntu" do
      let :facts do
        {
          :operatingsystem => 'Ubuntu',
          :lsbdistcodename => 'precise',
        }
      end
      it_behaves_like "a Linux OS"
      it { should contain_package('openssh') }
      it { should contain_service('sshd').with({
        :hasrestart => true
      })}
    end
  end


#  context "RedHat OS" do
#    it_behaves_like "a Linux OS" do
#      let :facts do
#        {
#          :operatingsystem => 'RedHat',
#          :osfamily        => 'RedHat',
#        }
#      end
#    end
#  end

  context "CentOS" do
    it_behaves_like "a Linux OS" do
      let :facts do
        {
        :operatingsystem => 'CentOS',
        :osfamily        => 'RedHat',
        :lsbdistcodename => 'Final',
       }
      end
    end
  end

  context "Gentoo" do
    let :facts do
    {
      :operatingsystem => 'Gentoo',
      :osfamily        => 'Gentoo',
    }
    end
    it_behaves_like "a Linux OS"
    it { should contain_class('sshd::gentoo') }
  end

  context "OpenBSD" do
    let :facts do
      {
      :operatingsystem => 'OpenBSD',
      :osfamily        => 'OpenBSD',
     }
    end
    it_behaves_like "a Linux OS"
    it { should contain_class('sshd::openbsd') }
  end

#  context "FreeBSD" do
#    it_behaves_like "a Linux OS" do
#      let :facts do
#        {
#        :operatingsystem => 'FreeBSD',
#        :osfamily        => 'FreeBSD',
#       }
#      end
#    end
#  end

end