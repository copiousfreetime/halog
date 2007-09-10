#-----------------------------------------------------------------------
# Documentation
#-----------------------------------------------------------------------

namespace :doc do
    
    # generating documentation locally
    Rake::RDocTask.new do |rdoc|
        rdoc.rdoc_dir   = HALog::SPEC.local_rdoc_dir
        rdoc.options    = HALog::SPEC.rdoc_options 
        rdoc.rdoc_files = HALog::SPEC.rdoc_files
    end

    desc "Deploy the RDoc documentation to #{HALog::SPEC.remote_rdoc_location}"
    task :deploy => :rerdoc do
        sh "rsync -zav --delete #{HALog::SPEC.local_rdoc_dir}/ #{HALog::SPEC.remote_rdoc_location}"
    end

    if HAVE_HEEL then
        desc "View the RDoc documentation locally"
        task :view => :rdoc do
            sh "heel --root  #{HALog::SPEC.local_rdoc_dir}"
        end
    end
end