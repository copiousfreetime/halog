module HALog
    class TCPLogMessage
        def initialize(line)
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