require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::StringLogMessage do
    it "responds to .parse" do
        HALog::StringLogMessage.parse("stuff").should_not == nil
    end

    it "responds to .parse!" do
        HALog::StringLogMessage.parse("stuff").should_not == nil
    end
    
    it "can be converted to a string" do
        HALog::StringLogMessage.parse("stuff").to_s.should == "stuff"
    end
    
end