ROOT = File.expand_path( File.join( File.dirname( __FILE__ ), ".." ) )
$: << File.join(ROOT,"lib")

require 'rubygems'
require 'benchmark'

include Benchmark
require 'halog'
require 'date'


TEST_LOG = File.join(ROOT, "tmp", "10k.log")
#TEST_LOG = "tmp/10k.log"
#TEST_LOG = "tmp/500.log"
#TEST_LOG = "tmp/1000.log"

now = DateTime.now

#bm(40) do |x|
#    x.report("Time.mktime (10K)") { 10_000.times { Time.mktime(now.year,
#                                                     now.month,
#                                                     now.day,
#                                                     now.hour,
#                                                     now.min,
#                                                     now.sec) } }
##    x.report("Date.civil (10K)") { 10_000.times { Date.civil(now.year,
#                                                       now.month, 
#                                                       now.day) } }
#end

db_perf = { }

bm(40) do |x| 
    File.open(TEST_LOG) do |tl|
        x.report("Iterate over lines") do
            tl.each { |line| nil }
        end
    end

    lines = IO.readlines(TEST_LOG)
    x.report("HALog::LogEntry.parse") do 
        lines.each { |line| HALog::LogEntry.parse(line) }
    end

    File.open(TEST_LOG) do |tl|
        x.report("HALog::LogParser.parse") do
            HALog::LogParser.new.parse(tl)
        end
    end

    File.open(TEST_LOG) do |tl|
        x.report("HALog::Datastore.import") do 
            HALog::DataStore.open("speed.db") do |ds|
                ds.import(tl)
                db_perf[' HALog::Datastore.import '] = ds.perf_report
            end
        end
    end
end

db_perf.each do |key,report|
    puts
    puts key.center(80, "=")
    puts report
end
