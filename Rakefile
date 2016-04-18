require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# return list of modules, either
# submodules or custom modules
# so we can check each array seperately
def modules_pattern (type)
  submodules = Array.new
  custom_modules = Array.new

  Dir['puppet/modules/*'].sort.each do |m|
    system("grep -q #{m} .gitmodules")
    if $?.exitstatus == 0
      submodules << m + '/**/*.pp'
    else
      custom_modules << m + '/**/*.pp'
    end
  end

  if type == 'submodule'
    submodules
  elsif type == 'custom'
    custom_modules
  else
  end

end



# redefine lint task with specific configuration
Rake::Task[:lint].clear
desc "boo"
PuppetLint::RakeTask.new :lint do |config|
  # Pattern of files to check, defaults to `**/*.pp`
  config.pattern           = modules_pattern('custom')
  config.ignore_paths     = ["spec/**/*.pp", "pkg/**/*.pp", "vendor/**/*.pp"]
  config.disable_checks   = ['documentation', '80chars']
  config.fail_on_warnings = false
end

# rake syntax::* tasks
PuppetSyntax.exclude_paths = ["**/vendor/**/*"]

desc "Run all puppet checks required for CI"
task :test => [:lint, :syntax , :validate, :spec]
