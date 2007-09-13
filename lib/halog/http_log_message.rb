module HALog
    class HTTPLogMessage
        
        # Regular expression to match this portion of a log entry
        #
        # 127.0.0.1:59791 [11/Sep/2007:16:46:47.787] http-forward http-forward/http0 0/0/39/58/1203 200 130 - JSESSIONID=96BB0AB0AEC812CAFBDDC ---- 0/0/0/0 0/0 {|curl/7.16.2 (i386-apple-darwin8.|*/*} {no-cache||0|Apache-Coyote/1.1|NSC_MC_QH_XFCBQQ=e2422cb129a0;ex} "GET / HTTP/1.1"
        #
        REGEX = %r<
                    \A              # starts at the beginning of the string
                    ([^\s:]+):      # everything up to the first colon in the client address    - 127.0.0.1
                    (\d+)\s+        # client port between color and space                       - 53407
                    \[(\d+)/        # day of the month                                          - 11
                    (\w{3})/        # month of the year its a 3 letter month, we convert to int - 9
                    (\d{4}):        # year                                                      - 2007
                    (\d\d):         # hour of the day, 24 hour mode                             - 16
                    (\d\d):         # minute of the hour                                        - 46
                    (\d\d)\.        # seconds                                                   - 47
                    (\d{3})\]       # micro-second                                              - 787
                    \s+(\S+)\s+     # frontend                                                  - http-forward
                    ([^\s/]+)/      # backend                                                   - http-forward
                    (\S+)\s+        # server                                                    - http0
                    (-?\d+)/        # request time (time from accept() to last header)          - 0
                    (-?\d+)/        # queue time (time the inbound connection is queue)         - 0
                    (-?\d+)/        # connect time (time to connect to backend)                 - 39
                    (-?\d+)/        # response time (time from connect to response start)       - 58
                    [+]?(\d+)\s+    # total_time from accept to connection close                - 1203
                                    # this may start with a '+' indicating 'option logasap'' was used
                                    
                    (-?\d+)\s+      # http status code                                          - 200
                    [+]?(\d+)\s+    # bytes read                                                - 130
                                    # this may start with a '+' indicating 'option logasap' was used
                                    
                    (\S+)\s+        # captured request cookie                                   - '-'
                    (\S+)\s+        # captured response cookie                                  - 'JSESSIONID=96BB0AB0AEC812CAFBDDC'
                    (\S{4})\s+      # termination state, 4 coded values, read the haproxy docs  - '----'
                    (\d+)/          # count of active sessions                                  - 0
                    (\d+)/          # count of frontend connections                             - 0
                    (\d+)/          # count of backend connections                              - 0
                    (\d+)\s+        # count of server connections                               - 0
                    (\d+)/          # incoming queue size                                       - 0
                    (\d+)\s+        # server queue size                                         - 0
                    
                    (\{[^}]*\})?\s* # captured request header values, pipe delimited            - '{|curl/7.16.2 (i386-apple-darwin8.|*/*}'   
                                    # may not exist if no request headers are being captured if so, request_headers returns nil
                                    
                    (\{[^}]*\})?\s* # captured response header values, pipe delimited           - '{no-cache||0|Apache-Coyote/1.1|NSC_MC_QH_XFCBQQ=e2422cb129a0;ex}'
                                    # may not exist if no response headers are being captured if so, response_headers returns nil
                                    
                    "(.*)"\Z        # the http request                                          - 'GET / HTTP/1.1'
                  >x                  
        
        # Using concat, just so I can get full code coverage stats
        FIELDS =      %w[ client_address client_port day month year hour minute second usecond frontend backend server ]
        FIELDS.concat %w[ request_time queue_time connect_time response_time total_time http_status bytes_read ]
        FIELDS.concat %w[ request_cookie response_cookie termination_state active_sessions frontend_connections backend_connections server_connections ]
        FIELDS.concat %w[ incoming_queue_size server_queue_size request_headers response_headers http_request ]
        FIELDS.freeze
                    
        INT_FIELDS =      %w[ client_port day year hour minute second usecond request_time queue_time connect_time response_time total_time ]
        INT_FIELDS.concat %w[ http_status bytes_read active_sessions frontend_connections backend_connections server_connections ]
        INT_FIELDS.concat %w[ incoming_queue_size server_queue_size ]
        INT_FIELDS.freeze
                         
        def initialize(line)
            @md = REGEX.match(line)
            raise InvalidLogMessageError.new("#{line} is not an HTTPLogMessge") if not @md
        end
        
        FIELDS.each_with_index do |field,idx|
            to_i = INT_FIELDS.include?(field) ? ".to_i" : ""
            module_eval <<-code
              def #{ field }
                  @#{ field } ||= @md[#{ idx + 1 }]#{ to_i }
              end
            code
        end
            
        # overwrites the eval'd month method
        def month
            @month ||= Date::ABBR_MONTHNAMES.index(@md[4])
        end

        def date
            @date ||= Date.new(year,month,day)
        end

        def time
            @time ||= Time.mktime(year,month,day,hour,minute,second,usecond)
        end
        
        def iso_time
            time.strftime("%Y-%m-%dT%H:%M:%S.") + "%03d" % usecond
        end

        class << self
            def parse(msg)
                HTTPLogMessage.parse!(msg) rescue nil
            end
            
            def parse!(msg)
                HTTPLogMessage.new(msg)
            end
        end
    end
end