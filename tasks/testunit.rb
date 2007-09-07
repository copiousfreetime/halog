require 'rake/testtask'
#-----------------------------------------------------------------------
# Testing - this is either test or spec, include the appropriate one
#-----------------------------------------------------------------------
namespace :test do

    task :default => :test

    Rake::TestTask.new do |t| 
        t.libs      = Halog::SPEC.require_paths
        t.test_files= FileList["test/**/*.rb"]
    end

end
