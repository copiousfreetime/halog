require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::LogEntry do
    before(:each) do
        @row_data = [
            "Oct 15 15:24:28 localhost.localdomain haproxy[18989]: 127.0.0.1:34550 [15/Oct/2007:15:24:28] relais-tcp Srv1 0/0/5007 0 -- 1/1/1 0/0\n",
            "Sep  6 00:24:41 localhost.localdomain haproxy[7211]: Proxy proxy1 started. ",
            "Sep  8 02:14:41 127.0.0.1 haproxy[14679]: Server for_assets/asset0 is DOWN. 0 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.",
            "Sep  8 02:14:41 127.0.0.1 haproxy[14679]: listener for_assets has no server available !",
            'Sep  8 02:54:15 127.0.0.1 haproxy[15226]: 10.10.11.20:56196 [08/Sep/2007:02:54:14.852] incoming static/asset0 2/0/2/5/18 200 121 - - ---- 1036/1036/999/99 0/0 "GET /images/rails.png HTTP/1.0"',
            'Sep  8 02:54:15 127.0.0.1 haproxy[15226]: 10.10.11.20:56742 [08/Sep/2007:02:54:14.949] incoming static/asset0 3/0/3/4/18 200 121 - - ---- 1020/1020/999/99 0/0 "GET /images/rails.png HTTP/1.0"'
            ]
    end
    
    def method_results_compare(method,results)
        @row_data.collect { |row| HALog::LogEntry.new(row).send(method) }.should == results
    end

    it "captures a month correctly" do
        method_results_compare(:log_month,[ 10, 9, 9, 9, 9, 9 ])
    end
    
    it "captures a day correctly" do
        method_results_compare(:log_day,[ 15, 6, 8, 8, 8, 8 ])
    end
    
    it "captures the hour correctly" do
        method_results_compare(:log_hour,[15,0,2,2,2,2])
    end
    
    it "captures the minute" do
        method_results_compare(:log_minute,[24,24,14,14,54,54])
    end
    
    it "captures the seconds" do
        method_results_compare(:log_second,[28,41,41,41,15,15])
    end
    
    it "captures the host" do
        method_results_compare(:log_host,%w[ localhost.localdomain localhost.localdomain 127.0.0.1 127.0.0.1 127.0.0.1 127.0.0.1 ])
    end
    
    it "captures the process name" do
        method_results_compare(:log_process_name,Array.new(6) { "haproxy" })
    end
    
    it "captures the process id" do
        method_results_compare(:log_pid, [ 18989, 7211, 14679, 14679, 15226, 15226])
    end
    
    it "captures the message" do
        method_results_compare(:log_message, [
            '127.0.0.1:34550 [15/Oct/2007:15:24:28] relais-tcp Srv1 0/0/5007 0 -- 1/1/1 0/0',
            'Proxy proxy1 started.',
            'Server for_assets/asset0 is DOWN. 0 active and 0 backup servers left. 0 sessions active, 0 requeued, 0 remaining in queue.',
            'listener for_assets has no server available !',
            '10.10.11.20:56196 [08/Sep/2007:02:54:14.852] incoming static/asset0 2/0/2/5/18 200 121 - - ---- 1036/1036/999/99 0/0 "GET /images/rails.png HTTP/1.0"',
            '10.10.11.20:56742 [08/Sep/2007:02:54:14.949] incoming static/asset0 3/0/3/4/18 200 121 - - ---- 1020/1020/999/99 0/0 "GET /images/rails.png HTTP/1.0"'
            ])
    end
    
    
        
end