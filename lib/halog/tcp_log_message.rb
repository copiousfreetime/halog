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
        
        def initialize(line)
            @md = REGEX.match(line)
            raise InvalidLogMessageError.new("#{line} is not a TCPLogMessage") if not @md
        end
        
        def client_address
            @client_address ||= @md[1]
        end
        
        def client_port
            @client_port ||= @md[2].to_i
        end
        
        def day
            @day ||= @md[3].to_i
        end
        
        def month
            @month ||= Date::ABBR_MONTHNAMES.index(@md[4])
        end
        
        def year 
            @year ||= @md[5].to_i
        end
        
        def date
            @date ||= Date.new(year,month,day)
        end
        
        def hour
            @hour ||= @md[6].to_i
        end
        
        def minute
            @minute ||= @md[7].to_i
        end
        
        def second
            @second ||= @md[8].to_i
        end
        
        def usecond
            @usecond ||= @md[9].to_i
        end
        
        def time
            @time ||= Time.mktime(year,month,day,hour,minute,second,usecond)
        end
        
        def frontend
            @frontend ||= @md[10]
        end
        
        def backend
            @backend ||= @md[11]
        end
        
        def server 
            @server ||= @md[12]
        end
        
        def queue_time
            @queue_time ||= @md[13].to_i
        end
        
        def connection_time
            @connection_time ||= @md[14].to_i
        end
        
        def total_time
            @total_time ||= @md[15].to_i
        end
        
        def byte_count
            @byte_count ||= @md[16].to_i
        end
        
        def termination_state
            @termination_state ||= @md[17]
        end
        
        def active_sessions
            @active_sessions ||= @md[18].to_i
        end
        
        def frontend_connections
            @frontend_connection ||= @md[18].to_i
        end
        
        def backend_connections
            @backend_connection ||= @md[19].to_i
        end
        
        def server_connections
            @server_connections ||= @md[20].to_i
        end
        
        def server_queue_size
            @server_queue_size ||= @md[21].to_i
        end
        
        def proxy_queue_size
            @proxy_queue_size ||= @md[22].to_i
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