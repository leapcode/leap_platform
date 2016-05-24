require 'spec_helper'

describe 'sshd::client' do

  shared_examples "a Linux OS" do
    it { should contain_file('/etc/ssh/ssh_known_hosts').with(
      {
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => '0',
        'mode'    => '0644',
      }
    )}
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
    it { should contain_package('openssh-clients').with({
      'name' => 'openssh-client'
    }) }
  end

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

end