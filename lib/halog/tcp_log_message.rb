module HALog
    class TCPLogMessage
        # sample row '127.0.0.1:53407 [11/Sep/2007:00:15:30.010] smtp-forward smtp-forward/smtp0 0/0/7061 21 -- 0/0/0/0 0/0'
        #   client address                                              127.0.0.1
        #   client port                                                 53407
        #   day, month, year                                            DD-MMM-YYYY - month converted to an integer
        #   hour, minute, second, micro second                          HH:MM:SS.UUU
        #   frontend                                                    smtp-forward
        #   backend / server                                            smtp-forward/smtp0
        #   queue_time / connection_time / total time                   0/0/7061
        #   total bytes                                                 21
        #   termination state                                           --
        #   active / frontend / backend / server connection counts      0/0/0/0
        #   incoming queue size / server queue size                     0/0
                
        REGEX = %r|\A([^\s:]+):(\d+)\s+\[(\d+)/(\w{3})/(\d{4}):(\d\d):(\d\d):(\d\d)\.(\d{3})\]\s+(\S+)\s+([^\s/]+)/(\S+)\s+(\d+)/(\d+)/(\d+)[+]?\s+(\d+)\s+(\S+)\s+(\d+)/(\d+)/(\d+)/(\d+)\s+(\d+)/(\d+)\Z|
        
        FIELDS = %w[ client_address client_port
                    day month year hour minute second usecond
                    frontend backend server 
                    queue_time connection_time total_time
                    bytes_read termination_state 
                    active_sessions frontend_connections backend_connections server_connections
                    server_queue_size proxy_queue_size
                ]
        INT_FIELDS = %w[ client_port day month year hour minute second usecond 
                        queue_time connection_time total_time bytes_read
                        active_sessions frontend_connections backend_connections server_connections
                        server_queue_size proxy_queue_size                        
            ]
        
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
                TCPLogMessage.parse!(msg) rescue nil
            end
            
            def parse!(msg)
                TCPLogMessage.new(msg)
            end
        end
    end
end