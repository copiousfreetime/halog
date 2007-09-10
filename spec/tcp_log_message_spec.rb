require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::TCPLogMessage do
    before(:each) do
        @row_data = "127.0.0.1:34550 [15/Oct/2007:15:24:28] relais-tcp Srv1 0/0/5007 0 -- 1/1/1 0/0\n"
        @entry = HALog::TCPLogMessage.new(@row_data)
    end
    
    it "captures the client ip" do
    end
    
    it "captures the client port" do
    end
    
    it "captures the date and time" do
    end
    
    it "captures the listener name" do
    end
    
    it "captures the server name" do
    end
    
    it "captures the queue time " do
    end
    
    it "captures the connection time" do
    end
    
    it "captures the total time" do
    end
    
    it "captures the number of bytes read" do
    end
    
    it "captures the termination state" do
    end
    
    it "captures the count of server connections" do
    end
    
    it "captures the count of listener connections" do
    end
    
    it "catpures the count of process connections" do
    end
    
    it "captures the position in the server queueu" do
    end

    it "captures the position in the listener queue" do
    end
end