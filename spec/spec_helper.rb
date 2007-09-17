require 'rubygems'
require 'spec'

$: << File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))
require 'halog'

def testing_logfile_short
    File.expand_path(File.join(File.dirname(__FILE__),"haproxy-short.log"))
end

def testing_logfile_part_1
    File.expand_path(File.join(File.dirname(__FILE__),"haproxy-1.log"))
end

def testing_logfile_part_2
    File.expand_path(File.join(File.dirname(__FILE__),"haproxy-2.log"))
end
    

require 'tmpdir'
require 'tempfile'
require 'fileutils'

