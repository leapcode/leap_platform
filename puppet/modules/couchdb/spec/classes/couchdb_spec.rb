require 'spec_helper'

describe 'couchdb' do
  context 'given it is a wheezy system' do
    let(:params) { {:admin_pw => 'foo'} }
    let(:facts) do
      {
      :operatingsystemrelease => '7',
      :operatingsystem           => 'Debian',
      :lsbdistcodename           => 'wheezy',
      }
    end
    it "should install couchrest 1.2" do
      should contain_package('couchrest').with({
        'ensure'=> '1.2',
      })
    end
  end
  context 'given it is a jessie system' do
    let(:params) { {:admin_pw => 'foo'} }
    let(:facts) do
      {
      :operatingsystemrelease => '8',
      :operatingsystem           => 'Debian',
      :lsbdistcodename           => 'jessie',
      }
    end
    it "should install latest couchrest version" do
      should contain_package('couchrest').with({
        'ensure'=> 'latest',
      })
    end
  end
end

