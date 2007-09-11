module HALog
    class HTTPLogMessage
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
        
        def initialize(line)
            @md = REGEX.match(line)
            raise InvalidLogMessageError.new("#{line} is not an HTTPLogMessge") if not @md
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