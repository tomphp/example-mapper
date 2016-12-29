begin
  require 'standalone_migrations'
  StandaloneMigrations::Tasks.load_tasks
rescue LoadError
  puts 'Skipping migrations'
end

namespace :tests do
  begin
    require 'rubocop/rake_task'

    RuboCop::RakeTask.new(:rubocop) do |task|
      task.fail_on_error = true
    end
  rescue LoadError
    puts 'Skipping rubocop'
  end

  begin
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new(:spec)
  rescue LoadError
    puts 'Skipping specs'
  end

  begin
    require 'cucumber'
    require 'cucumber/rake/task'

    Cucumber::Rake::Task.new(:features) do |t|
      t.cucumber_opts = 'features --format pretty'
    end
  rescue LoadError
    puts 'Skipping features'
  end
end

task :build do
  sh 'cd client; elm-make src/App.elm --output ../app/assets/app.js; cd ..'
end

desc 'Run all tests'
task tests: [
  'tests:rubocop',
  'tests:spec',
  'tests:features'
]

task default: :tests
