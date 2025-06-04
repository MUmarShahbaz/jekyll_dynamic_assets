# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/test_*.rb"]
  t.verbose = true
end

RuboCop::RakeTask.new(:rubocop)

task default: %i[test rubocop]
