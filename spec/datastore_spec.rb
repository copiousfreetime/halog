require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::DataStore do
    before(:each) do
        @ds = HALog::DataStore.new(":memory:")
        @log_lines = IO.readlines(File.join(File.dirname(__FILE__),'haproxy.log'))
        @io = File.open(File.join(File.dirname(__FILE__), 'haproxy.log'))
        @ds.db.trace("xx") { |data,stmt| puts "sql stmt : #{stmt.inspect} " }
    end
    
    after(:each) do
        @ds.close
        @io.close
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
        @ds.db.execute("SELECT count(1 cnt FROM imports").first['cnt'].should == 1
    end
    
    
    
end