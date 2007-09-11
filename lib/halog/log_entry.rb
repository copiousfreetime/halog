require 'date'
module HALog
    class InvalidLogEntryError < ::StandardError; end
    class InvalidLogMessageError < ::StandardError; end
    
    # represents  a single log entry from an HAproxy log.  Every line in the log should match this.
    class LogEntry
                
        #   'Sep  8 02:14:41 127.0.0.1 haproxy[14679]: listener for_assets has no server available !'
        #   month           Sep
        #   day             8
        #   year            (current year)
        #   date            (made from year, month, day)
        #   hour            2
        #   minute          14
        #   second          41
        #   time            (generated from year,month,day,hour,minute,second)
        #   host            127.0.0.1 - host that is emitting the log entry
        #   process_name    haproxy
        #   pid             14679
        #   raw_message     'listener for_assets has no server available !' 
        #   message         One of HTTPLogMessage, TCPLogMessage, StringLogMessage, parsed version of raw_message
        
        REGEX = %r/\A(\w{3})\s+(\d+)\s(\d\d):(\d\d):(\d\d)\s+(\S+)\s+([^\s\[]+)\[(\d+)\]:\s+(.*)\Z/
        
        def initialize(line)
            @md = REGEX.match(line)
            raise InvalidLogEntryError.new("#{line} is not a LogEntry") if not @md
        end
        
        # integer month of the log entry
        # the log entry is in teh Abbreviated form so we convert to the numerical form
        def month
            @month ||= Date::ABBR_MONTHNAMES.index(@md[1])
        end
        
        # convert from String to Integer format for the day of the month
        def day
            @day ||= @md[2].to_i
        end
        
        def year
            date.year
        end
        
        # create a full Date instance, year is not in the log entry so use the year the log was parsed
        def date
            @date ||= Date.civil(Date.today.year, month, day)
        end
        
        def hour
            @hour ||= @md[3].to_i
        end
        
        def minute
            @minute ||= @md[4].to_i
        end
        
        def second
            @second ||= @md[5].to_i
        end
        
        def time
            @time ||= Time.mktime(year,month,day,hour,minute,second)
        end
        
        def host
            @host ||= @md[6]
        end
        
        def process_name
            @process ||= @md[7]
        end
        
        def pid
            @pid ||= @md[8].to_i
        end
        
        def raw_message
            @raw_message ||= @md[9].strip
        end
        
        # convert the text of the message into a more knowledgable class
        # StringLogMessage is a failsafe, it just wraps up a String with a 
        # dukctype call for parse
        def message
            if not @message then
                [HTTPLogMessage, TCPLogMessage, StringLogMessage].each do |klass|
                    @message = klass.parse(raw_message)
                    break if @message
                end
            end
            return @message
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