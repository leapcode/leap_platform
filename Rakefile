require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# return list of modules, either
# submodules, custom or all modules
# so we can check each array seperately
def modules_pattern (type)
  submodules = Array.new
  custom_modules = Array.new
  all_modules = Array.new

  Dir['puppet/modules/*'].sort.each do |m|
    system("grep -q #{m} .gitmodules")
    if $?.exitstatus == 0
      submodules << m + '/**/*.pp'
    else
      custom_modules << m + '/**/*.pp'
    end
    all_modules << m + '/**/*.pp'
  end

  case type
    when 'submodule'
      submodules
    when 'custom'
      custom_modules
    when 'all'
      all_modules
  end
end

exclude_paths = ["**/vendor/**/*", "spec/fixtures/**/*", "pkg/**/*" ]

# redefine lint task so we don't lint submoudules for now
Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  # only check for custom manifests, not submodules for now
  config.pattern          = modules_pattern('custom')
  config.ignore_paths     = exclude_paths
  config.disable_checks   = ['documentation', '80chars']
  config.fail_on_warnings = false
end

# rake syntax::* tasks
PuppetSyntax.exclude_paths = exclude_paths
PuppetSyntax.future_parser = true

desc "Validate erb templates"
task :templates do
  Dir['**/templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c" unless template =~ /.*vendor.*/
  end
end

desc "Run all puppet checks required for CI (syntax , validate, spec, lint)"
task :test => [:syntax , :validate, :templates, :spec, :lint]
