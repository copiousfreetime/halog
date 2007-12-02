module HALog
    class TCPLogMessage
        # Regular expression to parse a row like this.
        #
        #   '127.0.0.1:53407 [11/Sep/2007:00:15:30.010] smtp-forward smtp-forward/smtp0 0/0/7061 21 -- 0/0/0/0 0/0'
        #
        REGEX = %r<
                    \A              # starts at the beginning of the string
                    ([^\s:]+):      # everything up to the first colon in the client address    - 127.0.0.1
                    (\d+)\s+        # client port between color and space                       - 53407
                    \[(\d+)/        # day of the month                                          - 11
                    (\w{3})/        # month of the year its a 3 letter month, we convert to int - 9
                    (\d{4}):        # year                                                      - 2007
                    (\d\d):         # hour of the day, 24 hour mode                             - 0
                    (\d\d):         # minute of the hour                                        - 15
                    (\d\d)\.        # seconds                                                   - 30
                    (\d{3})\]\s+    # micro-second                                              - 10
                    (\S+)\s+        # frontend                                                  - smtp-forward
                    ([^\s/]+)/      # backend                                                   - smtp-forward
                    (\S+)\s+        # server                                                    - smtp0
                    (-?\d+)/        # queue time (time the inbound connection is queue)         - 0
                    (-?\d+)/        # connect time (time to connect to backend)                 - 0
                    [+-]?(\d+)\s+   # total_time from accept to connection close                - 7061
                                    # this may start with a '+' indicating 'option logasap' was used
                                    
                    [+-]?(\d+)\s+   # bytes read                                                - 130
                                    # this may start with a '+' indicating 'option logasap' was used
                                    
                    (\S\S)\s+       # termination state, 2 coded values, read the haproxy docs  - '--'
                    (\d+)/          # count of active sessions                                  - 0
                    (\d+)/          # count of frontend connections                             - 0
                    (\d+)/          # count of backend connections                              - 0
                    (\d+)\s+        # count of server connections                               - 0
                    (\d+)/          # incoming queue size                                       - 0
                    (\d+)           # server queue size                                         - 0
                    \Z
                    >x
                                            
        FIELDS =      %w[ client_address client_port day month year hour minute second usecond frontend backend server ]
        FIELDS.concat %w[ queue_time connect_time total_time bytes_read termination_state ]
        FIELDS.concat %w[ active_sessions frontend_connections backend_connections server_connections server_queue_size proxy_queue_size ]
        FIELDS.freeze
        
        INT_FIELDS =      %w[ client_port day month year hour minute second usecond  queue_time connect_time total_time bytes_read ]
        INT_FIELDS.concat %w[ active_sessions frontend_connections backend_connections server_connections server_queue_size proxy_queue_size ]
        INT_FIELDS.freeze
        
        def initialize(line)
            @md = REGEX.match(line)
            raise InvalidLogMessageError.new("#{line} is not a TCPLogMessage") if not @md
        end
        
        FIELDS.each_with_index do |field,idx|
            to_i = INT_FIELDS.include?(field) ? ".to_i" : ""
            module_eval <<-code
              def #{ field }
                  @#{ field } ||= @md[#{ idx + 1 }]#{ to_i }
              end
            code
        end
        
        # redefinition of the eval'd month.
        def month
            @month ||= Date::ABBR_MONTHNAMES.index(@md[4])
        end

        def date
            @date ||= time.strftime("%Y-%m-%d")
        end
        
        def time
            @time ||= Time.mktime(year,month,day,hour,minute,second,usecond)
        end
        
        def iso_time
            @iso_time ||= (time.strftime("%Y-%m-%dT%H:%M:%S.") + "%03d" % usecond)
        end

        class << self
            def parse(msg)
                TCPLogMessage.parse!(msg) rescue nil
            end
            
            def parse!(msg)
                TCPLogMessage.new(msg)
            end
        end
    end
end