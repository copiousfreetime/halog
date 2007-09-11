require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::TCPLogMessage do
    before(:each) do
        @old_row_data = "127.0.0.1:34550 [15/Oct/2007:15:24:28.254] relais-tcp Srv1 0/0/5007 0 -- 1/1/1 0/0\n"
        @row_data = '127.0.0.1:53407 [11/Sep/2007:00:15:30.010] smtp-forward smtp-forward/smtp0 0/0/7061 21 -- 0/0/0/0 0/0'
        @msg = HALog::TCPLogMessage.new(@row_data)
    end
    
    it "captures the client ip" do
        @msg.client_address.should == "127.0.0.1"
    end
    
    it "captures the client port" do
        @msg.client_port.should == 53407
    end
    
    it "captures the year" do
        @msg.year.should == 2007
    end
    
    it "captures the month" do
        @msg.month.should == 9
    end
    it "captures the day" do
        @msg.day.should == 11
    end
    it "captures the date" do
        @msg.date.should == Date.new(2007,9,11)
    end
    it "captures the hour" do
        @msg.hour.should == 0
    end
    it "captures the minute" do
        @msg.minute.should == 15
    end
    it "captures the second" do
        @msg.second.should == 30
    end
    it "captures the microsecond" do
        @msg.usecond.should == 10
    end
    it "captures the time" do
        @msg.time.should == Time.mktime(2007,9,11,0,15,30,10)
    end
    
    it "captures the frontend name" do
        @msg.frontend.should == "smtp-forward"
    end
    
    it "captures the backend name" do
        @msg.backend.should == "smtp-forward"
    end
    
    it "captures the server name" do
        @msg.server.should == "smtp0"
    end
    
    it "captures the queue time " do
        @msg.queue_time.should == 0
    end
    
    it "captures the connection time" do
        @msg.connection_time.should == 0
    end
    
    it "captures the total time" do
        @msg.total_time.should == 7061
    end
    
    it "captures the number of bytes read" do
        @msg.byte_count.should == 21
    end
    
    it "captures the termination state" do
        @msg.termination_state.should == "--"
    end
    
    it "captures the count of sessions" do
        @msg.active_sessions.should == 0
    end
    
    it "captures the count of frontend connections" do
        @msg.frontend_connections.should == 0
    end
    
    it "catpures the count of backend connections" do
        @msg.backend_connections.should == 0
    end
    
    it "captures the count of per_server_connections" do
        @msg.server_connections.should == 0
    end
    
    it "captures the server queue size" do
        @msg.server_queue_size.should == 0
    end

    it "captures the proxy queue size" do
        @msg.proxy_queue_size.should == 0
    end
    
    it "can parse at the class level" do
        HALog::TCPLogMessage.parse(@row_data).class.should == HALog::TCPLogMessage
    end
    
    it "can raise an exception on a bad message" do
        lambda { HALog::TCPLogMessage.parse!(" bad message " ) }.should raise_error(HALog::InvalidLogMessageError)
    end
end