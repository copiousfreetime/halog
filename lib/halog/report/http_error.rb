module HALog
    module Report
        # The error report looks for all non 300 and 200 status codes in the database, and outputs
        # - a summary of the backed server emitting the codes and their counts
        # - a summary of the URL's that gave the codes (ordered by count)
        # - a summary of the ip address that recived the codes and their counts
        #
        # options may be passed in 
        #
        #    :limit_method -> one of 'days_back' or 'previous_runs'
        #    :limit_count  -> integer value > 1 as the number of 'days_back' or 'previous_runs'
        
        class HTTPError < Base

            attr_reader :options
            attr_reader :results

            def default_options
                {
                    'limit_method' => 'previous_runs',
                    'limit_count'  => 1
                }
            end

            def initialize(options = {})
                @options    = default_options
                options.each_pair do |key,value|
                    @options[key.to_s] = value.to_s
                end                
            end
            
            def code_count_for_column(column,ids)
                sql = <<-SQL
                    SELECT #{column}
                          ,http_status
                          ,count(id) AS cnt
                      FROM http_log_messages
                     WHERE import_id IN (#{ids.join(',')})
                       AND http_status >= 400
                  GROUP BY #{column},http_status
                  ORDER BY #{column},http_status ASC
                  SQL
                summary = {}
                @ds.db.execute(sql) do |row|
                    column_statuses = summary[row[column]] ||= {}
                    column_statuses[row['http_status']] = row['cnt']
                end
                return summary
            end
            
            def find_import_ids
                import_ids = []
                case options['limit_method']
                when 'days_back' 
                    sql = "SELECT distinct(id) AS id FROM imports WHERE import_date >= date('now', '-#{options['limit_count']} days') ORDER BY id"
                when 'previous_runs'
                    sql = "SELECT id FROM imports ORDER BY id DESC LIMIT #{options['limit_count']}"
                else
                    raise "Error: Unknown option to HTTPError 'limit_method' => #{options['limit_method']}"
                end
                
                @ds.db.execute(sql) { |row| import_ids << row['id'].to_i }
                
                return import_ids
            end
            
            def on(datastore)
                @ds = datastore
                @results = {}
                $stderr.puts "Running report..."
                import_ids = find_import_ids
                %w[ server client_address ].each do |column|
                    @results[column] = code_count_for_column(column,import_ids)
                end
                self
            end

            def to_s
                report = StringIO.new
                @results.each_pair do |column, result|
                    report.puts "#{"#{column}".center(20)} #{"Error Code".center(10)} #{"Count".center(10)}"
                    report.puts "-" * 70
                    result.each_pair do |server,code_counts|
                        code_counts.each_pair do |code,count|
                            report.puts "#{server.ljust(20)} #{code.to_s.ljust(10)} #{count.to_s.rjust(10)}"
                        end
                    end
                    report.puts
                end
                report.string
            end
        end
    end
end
        