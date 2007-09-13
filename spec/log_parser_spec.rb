require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::LogParser do
    before(:each) do
        good_row_data = [
            "Sep  6 00:24:41 localhost.localdomain haproxy[7211]: Proxy proxy1 started. ",
            "Sep  8 02:14:41 127.0.0.1 haproxy[14679]: Server for_assets/asset0 is DOWN. 0 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.",
            "Sep  8 02:14:41 127.0.0.1 haproxy[14679]: listener for_assets has no server available !",
            'Sep  8 02:54:15 127.0.0.1 haproxy[15226]: 10.10.11.20:56196 [08/Sep/2007:02:54:14.852] incoming static/asset0 2/0/2/5/18 200 121 - - ---- 1036/1036/999/99 0/0 {|} {close} "GET /images/rails.png HTTP/1.0"',
            'Sep  8 02:54:15 127.0.0.1 haproxy[15226]: 10.10.11.20:56742 [08/Sep/2007:02:54:14.949] incoming static/asset0 3/0/3/4/18 200 121 - - ---- 1020/1020/999/99 0/0 "GET /images/rails.png HTTP/1.0"',
            "Oct 15 15:24:28 localhost.localdomain haproxy[18989]: 127.0.0.1:34550 [15/Oct/2007:15:24:28.123] relais-tcp relais-backend/Srv1 0/0/5007 0 -- 1/1/1/1 0/0",
            ]
        @input = StringIO.new
        @good_bytes = @input.write(good_row_data.join("\n") + "\n")
        @input.rewind
    end
    
    it "parses log data from the start of a stream" do
        lp = HALog::LogParser.new.parse(@input) { |entry| nil }
        lp.starting_offset.should == 0
        lp.byte_count.should == @good_bytes
        lp.entry_count.should == 6
        lp.error_count.should == 0
        lp.first_entry_time.strftime("%Y-%m-%d %H:%M:%S").should == "2007-09-06 00:24:41"
        lp.last_entry_time.strftime("%Y-%m-%d %H:%M:%S").should == "2007-10-15 15:24:28"
    end
    
    it "can record error rows and spit them to stdout" do
        old_stderr = $stderr
        $stderr = StringIO.new
        bad_line = "Ful 12 this is not a valid line to parse"
        @input.seek(0,IO::SEEK_END)
        @input.puts bad_line
        @input.rewind
        
        lp = HALog::LogParser.new.parse(@input) { |entry| nil }
        lp.starting_offset.should == 0
        lp.byte_count.should == @good_bytes + bad_line.size + 1
        lp.entry_count.should == 6
        lp.error_count.should == 1
        lp.first_entry_time.strftime("%Y-%m-%d %H:%M:%S").should == "2007-09-06 00:24:41"
        lp.last_entry_time.strftime("%Y-%m-%d %H:%M:%S").should == "2007-10-15 15:24:28"
        
        $stderr.string.should == "Failure to parse line : #{bad_line}\n"
        $stderr = old_stderr
        
    end
end