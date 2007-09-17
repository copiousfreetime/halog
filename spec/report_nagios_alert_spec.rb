require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::Report::NagiosAlert do    
    before(:each) do
        @ds = HALog::DataStore.new("")
        @ds.import(File.open(testing_logfile_part_1))
        @old_stderr = $stderr
        $stderr = StringIO.new
        @report = HALog::Report::NagiosAlert.new
    end
    
    after(:each) do
        $stderr = @old_stderr
        @ds.close
    end
    
    it "reports error on stdout in nagios format when there is a 5XX error code" do
        @report.on(@ds).error_counts.size.should > 0
        @report.on(@ds).to_s.should =~ /Critical - 5XX errors/m
    end

    it "reports an okay message if everything is fine" do
        @ds.import(File.open(testing_logfile_part_2))
        r = @report.on(@ds)
        r.error_counts.size.should == 0
        r.to_s.should =~ /OK -/m
    end
end