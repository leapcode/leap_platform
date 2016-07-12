require 'spec_helper'

describe 'sshd::ssh_authorized_key' do

  context 'manage authorized key' do
    let(:title) { 'foo' }
    let(:ssh_key) { 'some_secret_ssh_key' }

    let(:params) {{
        :key => ssh_key,
    }}

    it { should contain_ssh_authorized_key('foo').with({
        'ensure' => 'present',
        'type'   => 'ssh-dss',
        'user'   => 'foo',
        'target' => '/home/foo/.ssh/authorized_keys',
        'key'    => ssh_key,
      })
    }
  end
  context 'manage authoried key with options' do
    let(:title) { 'foo2' }
    let(:ssh_key) { 'some_secret_ssh_key' }

    let(:params) {{
        :key      => ssh_key,
        :options  => ['command="/usr/bin/date"',
                      'no-pty','no-X11-forwarding','no-agent-forwarding',
                      'no-port-forwarding']
    }}

    it { should contain_ssh_authorized_key('foo2').with({
        'ensure'  => 'present',
        'type'    => 'ssh-dss',
        'user'    => 'foo2',
        'target'  => '/home/foo2/.ssh/authorized_keys',
        'key'     => ssh_key,
        'options' => ['command="/usr/bin/date"',
                      'no-pty','no-X11-forwarding','no-agent-forwarding',
                      'no-port-forwarding']
      })
    }
  end
end
