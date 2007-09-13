require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::HTTPLogMessage do
    before(:each) do
        @row_data = '127.0.0.1:59791 [11/Sep/2007:16:46:47.787] http-forward http-forward/http0 2/7/-1/58/1203 200 130 - JSESSIONID=96BB0AB0AEC812CAFBDDC ---- 3/5/7/9 11/13 {|curl/7.16.2 (i386-apple-darwin8.|*/*} {no-cache||0|Apache-Coyote/1.1|NSC_MC_QH_XFCBQQ=e2422cb129a0;ex} "GET / HTTP/1.1"'
        @row_data2 = '67.173.244.232:52924 [06/Sep/2007:12:32:52.916] proxy1 proxy1/mi 15/0/-1/-1/+15 -1 +390 - - CC-- 0/0/0/0 0/0 "GET /analysis/email_report/tag/dXNlcj1zdGV2ZUBjb2xsZWN0aXZlaW50ZWxsZWN0LmNvbSxyZXBvcnRfaWQ9MjEwMA==.png HTTP/1.1"'
        @msg = HALog::HTTPLogMessage.new(@row_data)
    end
    
    RESULTS = {
        :client_address         => "127.0.0.1",
        :client_port            => 59791,
        :year                   => 2007,
        :month                  => 9,
        :day                    => 11,
        :hour                   => 16,
        :minute                 => 46,
        :second                 => 47,
        :usecond                => 787,
        :frontend               => "http-forward",
        :backend                => "http-forward",
        :server                 => "http0",
        :request_time           => 2,
        :queue_time             => 7,
        :connect_time           => -1,
        :response_time          => 58,
        :total_time             => 1203,
        :http_status            => 200,
        :bytes_read             => 130,
        :request_cookie         => "-",
        :response_cookie        => "JSESSIONID=96BB0AB0AEC812CAFBDDC",
        :termination_state      => "----",
        :active_sessions        => 3,
        :frontend_connections   => 5,
        :backend_connections    => 7,
        :server_connections     => 9,
        :incoming_queue_size    => 11,
        :server_queue_size      => 13,
        :request_headers        => "{|curl/7.16.2 (i386-apple-darwin8.|*/*}",
        :response_headers       => "{no-cache||0|Apache-Coyote/1.1|NSC_MC_QH_XFCBQQ=e2422cb129a0;ex}",
        :http_request           => 'GET / HTTP/1.1'
        
    }
    RESULTS.each_pair do |meth,result|
        it "captures the #{meth}" do
            @msg.send(meth).should == result
        end
    end
    
    it "can create a hash of fields" do
        @msg.hash_of_fields(%w[ backend frontend server frontend_connections ]).should == { 'backend' => 'http-forward', 'frontend' => 'http-forward',
                                                                                  'server' => 'http0', 'frontend_connections' => 5}
    end
    
    it "has an iso time string" do
        @msg.iso_time.should == "2007-09-11T16:46:47.787"
    end
    
    it "captures the date" do
        @msg.date.should == Date.new(2007,9,11)
    end
    it "captures the time" do
        @msg.time.should == Time.mktime(2007,9,11,16,46,47,787)
    end
        
    it "can parse at the class level" do
        HALog::HTTPLogMessage.parse(@row_data).class.should == HALog::HTTPLogMessage
    end
    
    it "can raise an exception on a bad message" do
        lambda { HALog::HTTPLogMessage.parse!(" bad message " ) }.should raise_error(HALog::InvalidLogMessageError)
    end
end