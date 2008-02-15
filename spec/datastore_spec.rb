require File.join(File.dirname(__FILE__),"spec_helper.rb")

describe HALog::DataStore do
  before(:each) do
    @ds = HALog::DataStore.new(":memory:")
    @log_lines = IO.readlines(testing_logfile_short)
    @io = File.open(testing_logfile_short)
    #@ds.db.trace() { |data,stmt| puts "sql stmt : #{stmt} "}
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

  it "can incrementally import rows" do
    lines = IO.readlines(testing_logfile_part_1)
    tmp_log = Tempfile.new("halog-log-parser_test")
    tmp_log.write(lines[0..99])
    tmp_log.rewind

    @ds.import(tmp_log)

    perf_info = @ds.perf_info.dup

    sleep 1

    tmp_log.open
    tmp_log.seek(0,IO::SEEK_END)
    tmp_log.write(lines[100..199])
    tmp_log.rewind

    @ds.import(tmp_log,{ :incremental => true })
    @ds.db.execute("SELECT count(*) FROM log_entries").first[0].should == "200"
  end

  it "doesn't import information if there is nothing to import" do
    lines = IO.readlines(testing_logfile_part_1)
    tmp_log = Tempfile.new("halog-log-parser_test")
    tmp_log.write(lines[0..99])
    tmp_log.rewind
    @ds.import(tmp_log)

    perf_info = @ds.perf_info.dup

    sleep 1

    tmp_log.rewind
    @ds.import(tmp_log,{:incremental => true})
    @ds.db.execute("SELECT count(*) FROM log_entries").first[0].should == "100"
  end

  it "can handle imports with large counts" do
    parser = OpenStruct.new
    parser.first_entry_time = Time.at 1203067885
    parser.last_entry_time  = Time.at 1203073991
    parser.starting_offset  = 0
    parser.byte_count       = 2736709396
    parser.entry_count      = 11170274
    parser.error_count      = 0

    last_import_id = @ds.next_import_id
    @ds.finalize_import( @ds.db, last_import_id, parser )
    $stderr.puts @ds.db.execute("SELECT * from imports").inspect
    @ds.db.execute("SELECT count(*) from imports").first[0].should == "1"
  end
end
