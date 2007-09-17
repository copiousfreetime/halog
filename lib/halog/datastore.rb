require 'sqlite3'
require 'arrayfields'
require 'parsedate'

module HALog
    class DatastoreException < StandardError ; end;
    # permanent storage for the results of parsing the logfile.
    # this is backed by a SQLite 3 database with a few tables
    class DataStore
        attr_reader :db_loc
        attr_reader :db
        attr_reader :perf_info
    
        def initialize(db_loc = ":memory:")
            @db_loc = db_loc
            @db = ::SQLite3::Database.new(db_loc)
            if @db.execute("SELECT count(*) AS cnt FROM sqlite_master").first['cnt'].to_i == 0 then
                @db.execute_batch(IO.read(File.join(HALog::RESOURCE_DIR,"schema.sql")))
            end
            @perf_info = {'log_entries_insert' => { 'count' => 0, 'time' => 0},
                        'http_log_messages_insert' => { 'count' => 0, 'time' => 0},
                        'tcp_log_messages_insert' => { 'count' => 0, 'time' => 0},
                        'commit' => {'count' => 0, 'time' => 0 },
                        'parser' => {'count' => 0, 'time' => 0 },
                    }
                        
        end
                
        def close
            @db.close if @db
        end
        
        class << self
            def open(location)
                result = ds = DataStore.new(location)
                if block_given? then
                    yield ds
                    ds.close
                end
                return result
            end
            
            def log_entries_fields
                @log_entries_fields ||= %w[ iso_time hostname process pid raw_message ]
            end
            
            def tcp_log_messages_fields
                @tcp_log_messages_fields ||= %w[ log_entry_id client_address client_port iso_time 
                    frontend backend queue_time connect_time total_time bytes_read 
                    termination_state active_sessions frontend_connections backend_connections
                    server_connections server_queue_size proxy_queue_size ]
            end
                        
            def http_log_messages_fields
                @http_log_messages_fields ||= tcp_log_messages_fields + %w[ server request_time response_time
                                            http_status request_cookie response_cookie incoming_queue_size
                                            request_headers response_headers http_request ] - %w[ proxy_queue_size ]
            end
            
            def insert_sql_for(table)
                fields = %w[ import_id ] + send("#{table}_fields")
                params = fields.collect { |f| ":#{f}" }.join(',')
                "INSERT INTO #{table}(#{fields.join(',')}) VALUES (#{params})"
            end
        end
        
        def next_import_id(handle = nil)
            handle ||= db
            handle.execute("INSERT INTO imports(import_started_on) VALUES(datetime('now','localtime'))")
            handle.last_insert_row_id
        end
        
        def finalize_import(handle,import_id,parser)
            update_sql = <<-SQL
            UPDATE imports SET
                import_ended_on             = datetime('now','localtime'),
                first_entry_time            = :first_entry_time,
                last_entry_time             = :last_entry_time,
                starting_offset             = :starting_offset,
                byte_count                  = :byte_count,
                entry_count                 = :entry_count,
                error_count                 = :error_count
            WHERE id = #{import_id}
            SQL
            fields = %w[ first_entry_time last_entry_time starting_offset byte_count entry_count error_count ]
            handle.execute(update_sql,parser.hash_of_fields(fields))
        end
        
        def import(io,options = {})
            
            import_transaction(io) do |import_id,handle,stmts,last_import_info|
                                
                parse_options       = options[:incremental] ? last_import_info : {}
                log_entry_values    = { 'import_id' => import_id }
                results             = {}
                first_entry         = nil
                last_entry          = nil
                
                LogParser.new.parse(io,parse_options) do |entry|
                    t1 = Time.now
                    stmts['log_entries'].execute!( log_entry_values.merge(entry.hash_of_fields(HALog::DataStore::log_entries_fields)) )
                    log_entry_id = handle.last_insert_row_id
                    @perf_info['log_entries_insert']['count'] += 1
                    @perf_info['log_entries_insert']['time'] += (Time.now - t1)
                    
                    message_values = { 'import_id' => import_id, 'log_entry_id' => log_entry_id }
                    t3 = Time.now
                    case entry.message
                    when HTTPLogMessage
                        stmts['http_log_messages'].execute!( message_values.merge(entry.message.hash_of_fields(HALog::DataStore::http_log_messages_fields)) )
                        @perf_info['http_log_messages_insert']['count'] += 1
                        @perf_info['http_log_messages_insert']['time'] += (Time.now - t3)
                    when TCPLogMessage
                        stmts['tcp_log_messages'].execute!( message_values.merge(entry.message.hash_of_fields(HALog::DataStore::tcp_log_messages_fields)) )
                    when StringLogMessage
                        # do nothing
                        nil
                    end
                end
            end
            
        end 
        
        def perf_report
            report = StringIO.new
            name_width = @perf_info.keys.collect { |k| k.length }.max
            report.puts ["Stat".ljust(name_width), "Count".rjust(10), "Total Time".rjust(10), "Average Time".rjust(15)].join(" ")
            report.puts "-" * (name_width + 10 + 10 + 15 + 3)
            @perf_info.keys.sort.each do |stat|
                values = @perf_info[stat]
                avg = values['count'].to_f / values['time'].to_f
                avg_s = "%0.2f" % avg
                tt_s = "%0.2f" % values['time']
                report.puts [stat.ljust(name_width), values['count'].to_s.rjust(10), tt_s.rjust(10), avg_s.rjust(15)].join(' ')
            end
            report.string
        end
               
        
        private
        
        def import_transaction(io) 

            before = Time.now
            
            # Start the transaction, not using block format so that we can rollback sensibly if no items are found to
            # insert as LogEntries
            db.transaction
            
            import_id   = next_import_id(db)
            stmts       = {}            
            %w[ log_entries tcp_log_messages http_log_messages ].each do |table|                    
                stmts[table] = db.prepare( HALog::DataStore::insert_sql_for(table) )
            end
            
            parser = yield [import_id, db, stmts, last_import_info(db) ]
            
            stmts.values.each { |stmt| stmt.close }
            
            if parser.entry_count > 0
                @perf_info['parser']['count'] = parser.entry_count
                @perf_info['parser']['time'] = parser.parse_time
            
                finalize_import(db,import_id,parser)
                @perf_info['commit']['count'] += 1
                before = Time.now
                db.commit
                @perf_info['commit']['time'] += Time.now - before
                
            else
                $stderr.puts "No Data to import"
                db.rollback
            end
                
        end
        
        def last_import_info(db)
            # Get all the information for the previous import
            last_import_info    = {}
            db.query("SELECT * FROM imports WHERE id = (SELECT max(id) FROM imports WHERE import_ended_on IS NOT NULL)") do |result|
                row = result.next 
                result.columns.each_with_index do |c,idx|
                    last_import_info[c] = (row.nil?) ? 0 : convert_type(row[c],result.types[idx])
                end
            end
            return last_import_info
        end
        
        def convert_type(value,type)
            case type.downcase
            when 'integer'
                return Integer(value)
            when 'timestamp'
                return Time.mktime(*ParseDate.parsedate(value))
            when 'date'
                return Date.new(*ParseDate.parsedate(value)[0..2])
            else
                return value
            end
            
        end
    end
end