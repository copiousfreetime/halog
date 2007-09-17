require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::Report::Base do
    before(:each) do
        @ds = HALog::DataStore.new(":memory:")
        @ds.import(File.open(testing_logfile_short))
        @report = HALog::Report::Base.new
    end
    
    after(:each) do
        @ds.close
    end
    
    it "has a record of all other report classes" do
        %w[ httperror nagiosalert ].each do |r|
            HALog::Report::Base.types.should include(r)
        end
    end
    
    it "returns the report in when called on a datasources" do
        @report.on(@ds).should == @report
    end
    
    it "can be printed out" do
        @report.on(@ds).should respond_to('to_s')
    end
end