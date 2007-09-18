require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::Report::HTTPError do
    before(:all) do
        old_stderr = $stderr
        $stderr = StringIO.new
        @ds = HALog::DataStore.new(":memory:")
        @ds.import(File.open(testing_logfile_part_1))
        @ds.import(File.open(testing_logfile_part_2))
        $stderr = old_stderr
    end
    
    before(:each) do
        @old_stderr = $stderr
        $stderr = StringIO.new
        @report = HALog::Report::HTTPError.new
    end
    
    after(:each) do
        $stderr = @old_stderr
    end
    
    after(:all) do
        @ds.close
    end
    
    it "reports an error report" do
        @report.on(@ds).results.size.should > 0
        @report.on(@ds).to_s.should =~ /Error Code      Count client_address/m
    end

    it "can be configured to go back by multiple days" do
        report = HALog::Report::HTTPError.new({ 'limit_method' => 'days_back', 'count' => 3})
        report.on(@ds).results.size.should > 0
    end
    
    it "can be configured to go back by multipel runs" do
        report = HALog::Report::HTTPError.new({ 'limit_method' => 'previous_runs', 'count' => 3})
        report.on(@ds).results.size.should > 0
    end
    
    it "raises an error if an unknown 'limit_method' is used" do
        report = HALog::Report::HTTPError.new({ 'limit_method' => 'invalid', 'count' => 3})
        lambda { report.on(@ds) }.should raise_error(RuntimeError)
    end
        
end