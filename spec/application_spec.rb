require File.join(File.dirname(__FILE__),"spec_helper.rb")

require 'tempfile'

describe HALog::Application do
    before(:each) do
        @stdout = $stdout
        @stderr = $stderr
        @stdin  = $stdin
        
        @tmp_db = Tempfile.new("halog-spec.db")
        @tmp_outfile = Tempfile.new("halog-spec.output")
        
        $stdin = StringIO.new
        $stdout = StringIO.new
        $stderr = StringIO.new
    end
    
    after(:each) do
        $stdout = @stdout
        $stdin  = @stdin
        $stderr = @stderr
    end
    
    it "displays help" do
        begin
            HALog::Application.new(%w[ --help ]).run
        rescue SystemExit => se
            se.status.should == 0
            $stdout.string.size.should > 0
        end
    end
    
    it "displays error message when invalid optios are present" do
        begin
            HALog::Application.new(%w[ --invalid ]).run
        rescue SystemExit => se
            se.status.should == 1
            $stdout.string.size.should == 0
            $stderr.string.size.should > 0
        end
    end

    it "displays the version appropriately" do
        begin
            HALog::Application.new(%w[ --version ]).run
        rescue SystemExit => se
            se.status.should == 0
            $stdout.string.size.should > 0
            $stdout.string.should =~ /version #{HALog::VERSION}/
            $stderr.string.size.should == 0
        end
    end     
    
    it "uses the :memory: database by default" do
       HALog::Application.new(%W[ --input-file #{testing_logfile_short} --report httperror]).run
       $stderr.string.size.should > 0
       $stdout.string.size.should > 0
    end        
    
    it "parses a file and runs a report" do
        HALog::Application.new(%W[ --database :memory: --input-file #{testing_logfile_short} --report httperror ]).run
        $stderr.string.size.should > 0
        $stdout.string.size.should > 0
    end
    
    it "outputs the report to an output file if given" do
        HALog::Application.new(%W[ --database #{@tmp_db.path} --input-file #{testing_logfile_short} --report httperror --output-file #{@tmp_outfile.path}]).run
        $stderr.string.size.should > 0
        $stdout.string.size.should == 0
        @tmp_outfile.open
        @tmp_outfile.rewind
        @tmp_outfile.read.size.should > 0
    end 
end