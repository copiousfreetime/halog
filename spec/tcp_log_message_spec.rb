require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::TCPLogMessage do
    before(:each) do
        @old_row_data = "127.0.0.1:34550 [15/Oct/2007:15:24:28.254] relais-tcp Srv1 0/0/5007 0 -- 1/1/1 0/0\n"
        @row_data = '127.0.0.1:53407 [11/Sep/2007:00:15:30.010] smtp-forward smtp-forward/smtp0 0/-1/7061 21 -- 0/0/0/0 0/0'
        @msg = HALog::TCPLogMessage.new(@row_data)
    end
    
    TCP_LOG_MESSAGE_RESULTS = {
        :client_address         => "127.0.0.1",
        :client_port            => 53407,
        :year                   => 2007,
        :month                  => 9,
        :day                    => 11,
        :hour                   => 0,
        :minute                 => 15,
        :second                 => 30,
        :usecond                => 10,
        :frontend               => "smtp-forward",
        :backend                => "smtp-forward",
        :server                 => "smtp0",
        :queue_time             => 0,
        :connect_time           => -1,
        :total_time             => 7061,
        :bytes_read             => 21,
        :termination_state      => "--",
        :active_sessions        => 0,
        :frontend_connections   => 0,
        :backend_connections    => 0,
        :server_connections     => 0,
        :server_queue_size      => 0,
        :proxy_queue_size       => 0
    }
    
    TCP_LOG_MESSAGE_RESULTS.each_pair do |meth,result|
        it "captures the #{meth}" do
            @msg.send(meth).should == result
        end
    end
    
    it "can create a hash of fields" do
        @msg.hash_of_fields(%w[ year month day ]).should == { 'year' => 2007, 'month' => 9, 'day' => 11}
    end

    it "captures the date" do
        @msg.date.should == Date.new(2007,9,11)
    end

    it "captures the time" do
        @msg.time.should == Time.mktime(2007,9,11,0,15,30,10)
    end
    
    it "has an iso time string" do
        @msg.iso_time == "2007-09-11T00:15:30.010"
    end
    
    
    it "can parse at the class level" do
        HALog::TCPLogMessage.parse(@row_data).class.should == HALog::TCPLogMessage
    end
    
    it "can raise an exception on a bad message" do
        lambda { HALog::TCPLogMessage.parse!(" bad message " ) }.should raise_error(HALog::InvalidLogMessageError)
    end
end