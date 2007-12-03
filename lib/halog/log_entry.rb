require 'date'

module HALog
    class InvalidLogEntryError < ::StandardError; end
    class InvalidLogMessageError < ::StandardError; end
    
    # represents  a single log entry from an HAproxy log.  Every line in the log should match this.
    class LogEntry

        # Regular expression to match this whole log entry
        #
        #   'Sep  8 02:14:41 127.0.0.1 haproxy[14679]: listener for_assets has no server available !'        
        #
        REGEX = %r|
                \A
                (\w{3})\s+      # month of the year its a 3 letter month, we convert to int     - Sep
                (\d+)\s         # day of the month                                              - 8
                (\d\d):         # hour                                                          - 2
                (\d\d):         # minute                                                        - 14
                (\d\d)\s+       # second                                                        - 41
                (\S+)\s+        # host that is emitting the log entry                           - 127.0.0.1
                ([^\s\[]+)\[    # process name emitting the log entry                           - haproxy
                (\d+)\]:\s+     # process id of the process emitting the log entry              - 14679
                (.*)            # everything else                                               - 'listener for_assets has no server available !'
                \Z
                |x

        FIELDS = %w[ month day hour minute second hostname process pid raw_message ]
        INT_FIELDS = %w[ day hour minute second pid ]
                
        FIELDS.each_with_index do |field,idx|
            to_i = INT_FIELDS.include?(field) ? ".to_i" : ""
            module_eval <<-code
              def #{ field }
                  @#{ field } ||= @md[#{ idx + 1 }]#{ to_i }
              end
            code
        end
        
        TODAY = Date.today
        
        def initialize(line)
            @md = REGEX.match(line)
            raise InvalidLogEntryError.new("#{line} is not a LogEntry") if not @md
        end
        
        # this overwrites the automatically generated method above.
        # integer month of the log entry
        # the log entry is in teh Abbreviated form so we convert to the numerical form
        def month
            @month ||= Date::ABBR_MONTHNAMES.index(@md[1])
        end
        
        # create a full Date instance, year is not in the log entry so use the year the log was parsed
        def year
            @year ||= TODAY.year
        end
        
        def date
            @date ||= time.strftime("%Y-%m-%d")
        end
        
        def time
            @time ||= Time.mktime(year,month,day,hour,minute,second)
        end
        
        def iso_time
            @iso_time ||= time.strftime("%Y-%m-%dT%H:%M:%S")
        end

        # this ovewrites the eval'd method of the same name
        def raw_message
            @raw_message ||= @md[FIELDS.index('raw_message') + 1].strip
        end
        
        # convert the text of the message into a more knowledgable class
        # StringLogMessage is a failsafe, it just wraps up a String with a 
        # ducktype call for parse
        def message
            if not @message then
                [HTTPLogMessage, TCPLogMessage, StringLogMessage].each do |klass|
                    @message = klass.parse(raw_message)
                    break if @message
                end
            end
            return @message
        end
        
        # this turns out to be faster than using #send
        def to_sql_hash
            { 
                'iso_time'      => iso_time,
                'date'          => date,
                'hostname'      => hostname,
                'process'       => process,
                'pid'           => pid,
                'raw_message'   => raw_message
            }
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