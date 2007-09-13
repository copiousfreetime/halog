require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'halog'

def testing_logfile
    File.expand_path(File.join(File.dirname(__FILE__),"haproxy-short.log"))
end

require 'tmpdir'
require 'mktemp'
require 'fileutils'

# generate a temporary directory and create it

def my_temp_dir
    MkTemp.mktempdir(File.join(Dir.tmpdir,"halog-spec.XXXXXXXX"))
end
