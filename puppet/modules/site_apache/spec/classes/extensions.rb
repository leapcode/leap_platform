require 'spec_helper'

describe 'site_apache::common::extensions' do
  it "should include apache autostart" do
    should contain_file('/etc/systemd/system/apache2.service.d/auto_restart.conf').with_source('puppet:///modules/site_apache/apache_auto_restart.conf')
  end
end
