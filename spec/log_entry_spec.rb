require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::LogEntry do
    before(:each) do
        @row_data = [
            "Oct 15 15:24:28 localhost.localdomain haproxy[18989]: 127.0.0.1:34550 [15/Oct/2007:15:24:28.123] relais-tcp relais-backend/Srv1 0/0/5007 0 -- 1/1/1/1 0/0\n",
            "Sep  6 00:24:41 localhost.localdomain haproxy[7211]: Proxy proxy1 started. ",
            "Sep  8 02:14:41 127.0.0.1 haproxy[14679]: Server for_assets/asset0 is DOWN. 0 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.",
            "Sep  8 02:14:41 127.0.0.1 haproxy[14679]: listener for_assets has no server available !",
            'Sep  8 02:54:15 127.0.0.1 haproxy[15226]: 10.10.11.20:56196 [08/Sep/2007:02:54:14.852] incoming static/asset0 2/0/2/5/18 200 121 - - ---- 1036/1036/999/99 0/0 {|} {close} "GET /images/rails.png HTTP/1.0"',
            'Sep  8 02:54:15 127.0.0.1 haproxy[15226]: 10.10.11.20:56742 [08/Sep/2007:02:54:14.949] incoming static/asset0 3/0/3/4/18 200 121 - - ---- 1020/1020/999/99 0/0 "GET /images/rails.png HTTP/1.0"'
            ]
    end
    
    def method_results_compare(method,results)
        @row_data.collect { |row| HALog::LogEntry.new(row).send(method) }.should == results
    end

    it "should return an iso_time string" do
        method_results_compare(:iso_time, [ "2007-10-15T15:24:28",
                                                "2007-09-06T00:24:41",
                                                "2007-09-08T02:14:41",
                                                "2007-09-08T02:14:41",
                                                "2007-09-08T02:54:15",
                                                "2007-09-08T02:54:15"
                                                ])
    end
    it "captures a month correctly" do
        method_results_compare(:month,[ 10, 9, 9, 9, 9, 9 ])
    end
    
    it "captures a day correctly" do
        method_results_compare(:day,[ 15, 6, 8, 8, 8, 8 ])
    end
    
    it "creates a valid year" do
        method_results_compare(:year, Array.new(6) { Date.today.year })
    end
    
    it "creates the correct date" do
        this_year = Date.today.year
        method_results_compare(:date,[
            Date.new(this_year,10,15).to_s,
            Date.new(this_year,9,6).to_s,
            Date.new(this_year,9,8).to_s,
            Date.new(this_year,9,8).to_s,
            Date.new(this_year,9,8).to_s,
            Date.new(this_year,9,8).to_s,
            ])
    end
    
    it "captures the hour correctly" do
        method_results_compare(:hour,[15,0,2,2,2,2])
    end
    
    it "captures the minute" do
        method_results_compare(:minute,[24,24,14,14,54,54])
    end
    
    it "captures the seconds" do
        method_results_compare(:second,[28,41,41,41,15,15])
    end
    
    it "creates the correct time" do
        this_year = Date.today.year
        method_results_compare(:time,[
            Time.mktime(this_year,10,15,15,24,28),
            Time.mktime(this_year,9,6,0,24,41),
            Time.mktime(this_year,9,8,2,14,41),
            Time.mktime(this_year,9,8,2,14,41),
            Time.mktime(this_year,9,8,2,54,15),
            Time.mktime(this_year,9,8,2,54,15),            
            ])
        end
    
    it "captures the host" do
        method_results_compare(:hostname,%w[ localhost.localdomain localhost.localdomain 127.0.0.1 127.0.0.1 127.0.0.1 127.0.0.1 ])
    end
    
    it "captures the process" do
        method_results_compare(:process,Array.new(6) { "haproxy" })
    end
    
    it "captures the process id" do
        method_results_compare(:pid, [ 18989, 7211, 14679, 14679, 15226, 15226])
    end
    
    it "captures the message" do
        method_results_compare(:raw_message, [
            '127.0.0.1:34550 [15/Oct/2007:15:24:28.123] relais-tcp relais-backend/Srv1 0/0/5007 0 -- 1/1/1/1 0/0',
            'Proxy proxy1 started.',
            'Server for_assets/asset0 is DOWN. 0 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.',
            'listener for_assets has no server available !',
            '10.10.11.20:56196 [08/Sep/2007:02:54:14.852] incoming static/asset0 2/0/2/5/18 200 121 - - ---- 1036/1036/999/99 0/0 {|} {close} "GET /images/rails.png HTTP/1.0"',
            '10.10.11.20:56742 [08/Sep/2007:02:54:14.949] incoming static/asset0 3/0/3/4/18 200 121 - - ---- 1020/1020/999/99 0/0 "GET /images/rails.png HTTP/1.0"'
            ])
    end
    
    it "creates the correct message class" do
        result_klasses = [HALog::TCPLogMessage, HALog::StringLogMessage, HALog::StringLogMessage, 
                        HALog::StringLogMessage, HALog::HTTPLogMessage, HALog::HTTPLogMessage]
        @row_data.collect { |row| HALog::LogEntry.parse(row).message.class }.should == result_klasses
    end
    
    it "raises an expception if the line cannot be parsed" do
        lambda { HALog::LogEntry.new(" this should not parse ") }.should raise_error(HALog::InvalidLogEntryError)
        lambda { HALog::LogEntry.parse!(" this should not parse2")}.should raise_error(HALog::InvalidLogEntryError)
    end
    
    it "should return nil if using non alerting parser" do
        HALog::LogEntry.parse(" this also does not parse ").should == nil
    end
    

    
end