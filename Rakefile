require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# redefine lint task with specific configuration
Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  # Pattern of files to check, defaults to `**/*.pp`
  config.pattern          = ['puppet/modules/site_*/**/*.pp']
  #config.ignore_paths    = ['puppet/modules/apache/**/*.pp']
  config.ignore_paths     = ["spec/**/*.pp", "pkg/**/*.pp"]
  config.disable_checks   = ['documentation', '80chars']
  config.fail_on_warnings = false
end

# rake syntax::* tasks
PuppetSyntax.exclude_paths = ["**/vendor/**/*"]

desc "Run all puppet checks required for CI"
task :test => [:lint, :syntax , :validate, :spec]
