module HALog
    module Report
        # The nagios error report looks for 5XX errors in the last import and outputs to stdout a
        # message in the nagios message format
        class NagiosAlert < Base
            
            
            STATE_OK        = 0
            STATE_WARNING   = 1
            STATE_CRITICAL  = 2
            STATE_UNKNOWN   = 3
            STATE_DEPENDENT = 4
            
            attr_reader :error_counts
            
            def initialize
                @error_counts = {}
            end
            
            def on(datastore)
                sql = <<-SQL
                    SELECT log.http_status AS status
                          ,count(log.id) AS cnt
                      FROM http_log_messages AS log
                     WHERE log.import_id = (SELECT max(id) FROM imports WHERE import_ended_on IS NOT NULL)
                       AND log.http_status >= 500
                  GROUP BY status
                  ORDER BY status
                SQL
                datastore.db.query(sql) do |result|
                    result.each do |row|
                        @error_counts[row['status']] = row['cnt'].to_i
                    end
                end
                
                self
            end

            def to_s
                report = StringIO.new
                report.print "HAPROXY 5XX CHECK : "
                if @error_counts.size > 0 then
                    report.print "CRITICAL : "
                    report.print @error_counts.collect { |s,c| "#{s} => #{c}" }.join(',')
                else
                    report.print "#{STATE_OK} : OK : No HTTP 5XX errors found."
                end
                report.string
            end
        end
    end
end