require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::DataStore do
    before(:each) do
        @ds = HALog::DataStore.new(":memory:")
        @log_lines = IO.readlines(testing_logfile_short)
        @io = File.open(testing_logfile_short)
       # @ds.db.trace() { |data,stmt| puts "sql stmt : #{stmt} "}
    end
    
    after(:each) do
        @io.close
        @ds.close
    end
    
    it "creates or attaches to a valid SQLite database" do
        @ds.db.class.should == ::SQLite3::Database
        @ds.db.table_info("imports").size.should > 0
        @ds.db.table_info("log_entries").size.should > 0
        @ds.db.table_info("tcp_log_messages").size.should > 0
        @ds.db.table_info("http_log_messages").size.should > 0
    end
    
    it "can create a new import id" do
        @ds.next_import_id.should == 1
    end
    
    it "can be opened with a block" do
        HALog::DataStore.open(":memory:") do |ds|
            ds.db.table_info("imports").size.should > 0
            ds.db.table_info("log_entries").size.should > 0
            ds.db.table_info("tcp_log_messages").size.should > 0
            ds.db.table_info("http_log_messages").size.should > 0
        end
    end
    
    it "can import rows" do
        @ds.import(@io)
        row_counts = {
            'imports' => 1,
            'log_entries' => 201,
            'tcp_log_messages' => 1,
            'http_log_messages' => 119,

        } 
        
        row_counts.each_pair do |table,count|
            @ds.db.execute("SELECT count(1) cnt FROM #{table}").first['cnt'].to_i.should == count
        end
    end
    
    
    
end