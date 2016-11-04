source "https://rubygems.org"

group :test do
  gem "rake"
  gem "rspec", '< 3.2.0'
  gem "puppet", ENV['PUPPET_VERSION'] || ENV['GEM_PUPPET_VERSION'] || ENV['PUPPET_GEM_VERSION'] || '~> 3.7.0'
  gem "facter", ENV['FACTER_VERSION'] || ENV['GEM_FACTER_VERSION'] || ENV['FACTER_GEM_VERSION'] || '~> 2.2.0'
  gem "rspec-puppet"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem "mocha"
end
