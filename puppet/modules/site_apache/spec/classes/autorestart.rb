require 'spec_helper'

describe 'site_apache::common::autorestart' do
  it "should include apache autorestart" do
    should contain_file('/etc/systemd/system/apache2.service.d/autorestart.conf').with_source('puppet:///modules/site_apache/autorestart.conf')
  end
end
