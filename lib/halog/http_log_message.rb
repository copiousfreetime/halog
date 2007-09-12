module HALog
    class HTTPLogMessage
        # 127.0.0.1:59791 [11/Sep/2007:16:46:47.787] http-forward http-forward/http0 0/0/39/58/1203 200 130 - JSESSIONID=96BB0AB0AEC812CAFBDDC ---- 0/0/0/0 0/0 {|curl/7.16.2 (i386-apple-darwin8.|*/*} {no-cache||0|Apache-Coyote/1.1|NSC_MC_QH_XFCBQQ=e2422cb129a0;ex} "GET / HTTP/1.1"
        #   client address                                              127.0.0.1
        #   client port                                                 53407
        #   day, month, year                                            11, 9, 2007 - month converted to an integer
        #   hour, minute, second, micro second                          16:46:47.787
        #   frontend                                                    http-forward
        #   backend / server                                            htttp-forward/http0
        #   queue_time / connection_time / total time                   0/0/39/58/1203
        #   http return code                                            200
        #   total bytes read                                            130
        #   request cookie                                              - 
        #   response cookie                                             SESSIONID=96BB0AB0AEC812CAFBDDC
        #   termination state                                           ----
        #   active / frontend / backend / server connection counts      0/0/0/0
        #   incoming queue size / server queue size                     0/0
        #   captured request headers                                    {|curl/7.16.2 (i386-apple-darwin8.|*/*}
        #   captured response headers                                   {no-cache||0|Apache-Coyote/1.1|NSC_MC_QH_XFCBQQ=e2422cb129a0;ex}
        #   http request                                                "GET / HTTP/1.1"
        
        REGEX = %r|\A([^\s:]+):(\d+)\s+\[(\d+)/(\w{3})/(\d{4}):(\d\d):(\d\d):(\d\d)\.(\d{3})\]\s+(\S+)\s+([^\s/]+)/(\S+)\s+(\d+)/(\d+)/(\d+)/(\d+)/(\d+)[+]?\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S{4})\s+|
        
        FIELDS = %w[ client_address client_port 
                    day month year hour minute second usecond 
                    frontend backend server 
                    request_time queue_time connect_time response_time total_time 
                    http_status bytes_read
                    request_cookie response_cookie
                    termination_state
                    active_sessions frontends backends servers
                    incoming_queue_size server_queue_size
                    request_headers response_headers
                    http_request]
                    
        INT_FIELDS = %w[ client_port day year hour minute second usecond 
                         request_time queue_time connect_time response_time total_time 
                         http_status bytes_read 
                         active_sessions frontends backends servers
                         incoming_queue_size server_queue_size
                         ]
                         
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
            
        def month
            @month ||= Date::ABBR_MONTHNAMES.index(@md[4])
        end

        def date
            @date ||= Date.new(year,month,day)
        end

        def time
            @time ||= Time.mktime(year,month,day,hour,minute,second,usecond)
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