require 'date'
module HALog
    class InvalidLogEntryError < ::StandardError; end
    
    # represents  a single log entry from an HAproxy log.  Every line in the log should evaluate to this
    class LogEntry
                
        REGEX = %r/\A(\w{3})\s+(\d+)\s(\d\d):(\d\d):(\d\d)\s+(\S+)\s+([^\s\[]+)\[(\d+)\]:\s+(.*)\Z/
        
        def initialize(line)
            @md = REGEX.match(line)
            raise InvalidLogEntryError.new("#{line} is not a LogEntry") if not @md
        end
        
        # integer month of the log entry
        # the log entry is in teh Abbreviated form so we convert to the numerical form
        def log_month
            @log_month ||= Date::ABBR_MONTHNAMES.index(@md[1])
        end
        
        # convert from String to Integer format for the day of the month
        def log_day
            @log_day ||= Integer(@md[2])
        end
        
        def log_year
            log_date.year
        end
        
        # create a full Date instance, year is not in the log entry so use the year the log was parsed
        def log_date
            @log_date ||= Date.civil(Date.today.year, log_month, log_day)
        end
        
        def log_hour
            @log_hour ||= Integer(@md[3])
        end
        
        def log_minute
            @log_minute ||= Integer(@md[4])
        end
        
        def log_second
            @log_second ||= Integer(@md[5])
        end
        
        def log_host
            @log_host ||= @md[6]
        end
        
        def log_process_name
            @log_process ||= @md[7]
        end
        
        def log_pid
            @log_pid ||= Integer(@md[8])
        end
        
        def log_message
            @log_message || @md[9].strip
        end
        
        class << self
            def parse(line)
                parse!(line) rescue nil
            end
            
            def parse!(line)
                LogEntry.new(line)
            end
        end
    end
end