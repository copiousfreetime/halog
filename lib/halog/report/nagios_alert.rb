module HALog
    module Report
        # The nagios error report looks for 5XX errors in the last import and outputs to stdout a
        # message in the nagios message format
        class NagiosAlert < Base
            
            def initialize
                @error_counts = {}
            end
            
            def on(datastore)
                sql = <<-SQL
                    SELECT log.http_status AS status
                          ,count(log.id) AS cnt
                      FROM http_log_messages AS log
                     WHERE log.import_id = (SELECT max(id) FROM imports WHERE import_ended_on IS NOT NULL)
                  ORDER BY status
                  GROUP BY status
                SQL
                datastore.query(sql) do |result|
                    result.each do |row|
                        @error_counts[row['status']] = row['cnt'].to_i
                    end
                end
                
                self
            end

            def to_s
                report = StringIO.new
                if @error_counts.size > 0 then
                    @error_counts.each_pair do |status, count|
                        report.puts "#{status} : #{count}"
                    end
                else
                    report.puts "OK"
                end
                report.string
            end
        end
    end
end