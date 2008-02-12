module HALog
  module Report
    # The error report looks for all non 300 and 200 status codes in the database, and outputs
    # - a summary of the backed server emitting the codes and their counts
    # - a summary of the URL's that gave the codes (ordered by count)
    # - a summary of the ip address that recived the codes and their counts
    #
    # options may be passed in 
    #
    #    :limit_method 
    #         -> one of 'days_back' or 'previous_runs'
    #    :limit_count  
    #         -> integer value > 1 as the number of 'days_back' or 'previous_runs'
    #    :minimum_http_status 
    #         -> integer value indicating the minimum http status to run the report for
    #
    class HTTPError < Base

      attr_reader :options
      attr_reader :results

      def default_options
        {
          'limit_method'        => 'days_back',
          'limit_count'         => 1,
          'minimum_http_status' => 500
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
                       AND http_status >= #{options['minimum_http_status']}
                  GROUP BY http_status,#{column}
                  ORDER BY http_status,cnt,#{column} ASC
                  SQL
        summary = {}
        @ds.db.execute(sql) do |row|
          http_codes = summary[row['http_status']] ||= {}
          http_codes[row[column]] = row['cnt']  
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
                %w[ server client_address http_request ].each do |column|
                  @results[column] = code_count_for_column(column,import_ids)
                end
                self
      end

      def to_s
        report = StringIO.new
        @results.each_pair do |column, result|
          next if result.size == 0
          report.puts "#{"Error Code".ljust(10)} #{"Count".rjust(10)} #{"#{column}".ljust(20)} "
          report.puts "-" * 70
          result.keys.sort.each do |status_code|
            result[status_code].each_pair do |stat,count|
              report.puts "#{status_code.to_s.ljust(10)} #{count.to_s.rjust(10)} #{stat.ljust(20)}"
            end
          end
          report.puts
        end
        report.string
      end
    end
  end
end

