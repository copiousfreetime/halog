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

    spec.summary            = "A log parser and analyzer for HAproxy logs."
    spec.description        = <<-DESC
                A log parser and analyzer for HAproxy logs.
                DESC

    spec.extra_rdoc_files   = FileList["[A-Z]*"]
    spec.has_rdoc           = true
    spec.rdoc_main          = "README"
    spec.rdoc_options       = [ "--line-numbers" , "--inline-source" ]

    spec.test_files         = FileList["spec/**/*.rb"]
    spec.files              = spec.test_files + spec.extra_rdoc_files + 
                              FileList["lib/**/*.rb", "data/**/*"]

    spec.executable         = spec.name

    # add dependencies
    spec.add_dependency("sqlite3-ruby", ">= 1.2.1")
    spec.add_dependency("arrayfields", ">= 3.7.0")
    spec.add_dependency("rake", ">= 0.7.3")

    spec.platform           = Gem::Platform::RUBY

    spec.local_rdoc_dir     = "doc/rdoc"
    spec.remote_rdoc_dir    = ""
    spec.local_coverage_dir = "doc/coverage"
    spec.remote_coverage_dir= ""

    spec.remote_user        = "jjh"
    spec.remote_site_dir    = "#{spec.name}/"

  end
end


