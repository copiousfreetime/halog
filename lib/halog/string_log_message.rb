module HALog
    class StringLogMessage
        def initialize(msg)
            @msg = msg
        end
        
        def to_s
            @msg.to_s
        end
        
        class << self
            def parse(msg)
                parse!(msg)
            end
            
            def parse!(msg)
                StringLogMessage.new(msg)
            end
        end
    end
end