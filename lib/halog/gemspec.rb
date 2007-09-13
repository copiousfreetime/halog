require 'rubygems'
require 'halog/specification'
require 'halog/version'
require 'rake'

# The Gem Specification plus some extras for halog.
module HALog
    SPEC = HALog::Specification.new do |spec|
                spec.name               = "halog"
                spec.version            = HALog::VERSION
                spec.rubyforge_project  = "copiousfreetime"
                spec.author             = "Jeremy Hinegardner"
                spec.email              = "jeremy@hinegardner.org"
                spec.homepage           = "http://copiousfreetime.rubyforge.org/"

                spec.summary            = "A Summary of halog."
                spec.description        = <<-DESC
                A longer more detailed description of halog.
                DESC

                spec.extra_rdoc_files   = FileList["[A-Z]*"]
                spec.has_rdoc           = true
                spec.rdoc_main          = "README"
                spec.rdoc_options       = [ "--line-numbers" , "--inline-source" ]

                spec.test_files         = FileList["spec/**/*.rb", "test/**/*.rb"]
                spec.files              = spec.test_files + spec.extra_rdoc_files + 
                                          FileList["lib/**/*.rb", "resources/**/*"]
                
                spec.executable         = spec.name
                
                # add dependencies
                spec.add_dependency("sqlite3-ruby", ">= 1.2.1")
                spec.add_dependency("arrayfields", ">= 3.7.0")
                
                spec.platform           = Gem::Platform::RUBY

                spec.local_rdoc_dir     = "doc/rdoc"
                spec.remote_rdoc_dir    = "rdoc"
                spec.local_coverage_dir = "doc/coverage"
                spec.remote_coverage_dir= "coverage"

                spec.remote_user        = "jjh"
                spec.remote_site_dir    = ""

           end
end


