require 'sqlite3'

module HALog
    # permanent storage for the results of parsing the logfile.
    # this is backed by a SQLite 3 database with a few tables
    class DataStore
        attr_reader :db_loc
    
        def initialize(db_loc = ":memory:")
            @db_loc = db_loc
        end
        
        def db
            if not @db then
                @db = Sqlite3::Database.new(db_loc)
                if @db.execute("SELECT count(*) AS cnt FROM sqlite_master").first['cnt'].to_i == 0 then
                    @db.execute(IO.read(File.join(HALog::RESOURCE_DIR),"schema.sql"))
                end
            end
            return @db
        end
        
        def close
            @db.close if @db
        end
        
        class << self
            def open(location, options = {} )
                result = ds = DataStore.new(location, options)
                if block_given? then
                    result = yield ds
                    ds.close
                end
                return result
            end
            
            def log_entries_fields
                @log_entries_fields ||= %w[ time hostname process pid]
            end
            
            def tcp_log_messages_fields
                @tcp_log_messages_fields ||= %w[ client_address client_port time 
                    frontend backend queue_time connect_time total_time bytes_read 
                    termination_state active_sessions frontend_connections backend_connections
                    server_connections server_queue_size proxy_queue_size ]
            end
                        
            def http_log_messages_fields
                @http_log_messages_fields ||= tcp_log_messages_fields + %w[ server request_time response_time
                                            http_status request_cookie response_cookie incoming_queue_size
                                            request_headers response_headers http_request ]
            end
            
            def insert_sql_for(table)
                fields_set = send("#{table}_fields")
                params = field_set.collect { |f| ":#{f}" }.join(',')
                "INSERT INTO #{table}(#{field_set.join(',')}) VALUES (#{params})"
            end
        end
        
        def next_import_id(handle)
            handle.execute("INSERT INTO import(import_started_on) VALUES(datetime('now','localtime'))")
            handle.last_insert_row_id
        end
        
        def finalize_import(handle,import_id,parser)
            update_sql = <<-SQL
            UPDATE import SET
                import_ended_on             = datetime('now','localtime'),
                first_entry_time            = :first_entry_time,
                last_entry_time             = :last_entry_time,
                first_entry_start_offset    = :first_entry_start_offset,
                last_entry_end_offset       = :last_entry_end_offset,
                entry_count                 = :entry_count
            WHERE id = #{import_id}
            SQL
            handle.execute(update_sql,parser.hash_of_fields(%w[ first_entry_time last_entry_time first_entry_start_offset
                                                                last_entry_end_offset entry_count]))
        end
        
        def import(io,options = {})
            # TODO: make sure to mark the position in the input stream or do whatever is necessary to roll forward
            # to the point to start the parsing.
            
            import_transaction(io) do |import_id,handle,stmts,last_import_info|
                
                parse_options       = options[:incremental] ? last_import_info : {}
                log_entry_values    = { :import_id => import_id }
                results             = {}
                first_entry         = nil
                last_entry          = nil
                
                LogParser.new.parse(io,parse_options) do |entry|
                    stmts['log_entries'].execute( log_entry_values.merge(entry.hash_of_fields(log_entry_fields)) )
                    log_entry_id = handle.last_insert_row_id
                    
                    message_values = { :import_id => import_id, :log_entry_id => log_entry_id }
                    case entry.message
                    when HTTPLogMessage
                        stmts['http_log_messages'].execute( message_values.merge(entry.message.hash_of_fields(http_log_messages_fields)) )
                    when TCPLogMessage
                        stmts['tcp_log_messages'].execute( message_values.merge(entry.message.hash_of_fields(tcp_log_messages_fields)) )
                    end
                end
                # returning the log parser from the yield
            end
            
        end        
        
        private
        
        def import_transaction(io) 
            db.transaction do |trans_handle|
                last_import_info    = trans_handle.query("SELECT * FROM imports WHERE id = (SELECT max(id) FROM imports)")
                import_id           = next_import_id(trans_handle)
                
                stmts               = {}
                %w[ log_entries tcp_log_messages http_log_messages ].each do |table|
                    smts[table] = trans_handle.prepare( insert_sql_for(table) )
                end
                
                parser = yield [import_id, trans_handle, stmts, last_import_info ]

                stmts.values.each { |h| h.close }                
                finalize_import(trans_handle,import_id,parser)
            end
        end
    end
end