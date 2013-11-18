require 'rake'
require 'active_record'
require 'rspec/core/rake_task'

task :default => :test
task :test do
  Rake::Task['db:test_prepare'].invoke
  RSpec::Core::RakeTask.new(:test)
end

namespace :db do
  task :migrate do
    ActiveRecord::Base.establish_connection(YAML::load(File.open('db/database.yaml'))['development'])
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  task :test_prepare do
    ENV['VENMO_ENV'] = 'test'
    test_path = YAML::load(File.open('db/database.yaml'))['test']['database']
    File.delete(test_path) if File.exists?(test_path)
    ActiveRecord::Base.establish_connection(YAML::load(File.open('db/database.yaml'))['test'])
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
