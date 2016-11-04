require 'bundler'
Bundler.require(:rake)

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rspec-system/rake_task'

PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'
PuppetLint.configuration.send("disable_80chars")

puppet_module='sshd'
task :librarian_spec_prep do
  sh 'librarian-puppet install --path=spec/fixtures/modules/'
end
task :spec_prep => :librarian_spec_prep
task :default => [:spec, :lint]
