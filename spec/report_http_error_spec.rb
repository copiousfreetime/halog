require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::Report::HTTPError do
    before(:each) do
        @ds = HALog::DataStore.new(":memory:")
        @old_stderr = $stderr
        $stderr = StringIO.new
        
        @ds.import(File.open(testing_logfile_part_1))
        @ds.import(File.open(testing_logfile_part_2))

        @report = HALog::Report::HTTPError.new
    end
    
    after(:each) do
        @ds.close
        $stderr = @old_stderr
    end
    
    it "reports an error report" do
        $stderr.string.should =~ /parsed: 2048/m 
        @report.on(@ds).results.size > 0
        @report.on(@ds).to_s.should =~ /client_address    Error Code   Count/m
    end

end