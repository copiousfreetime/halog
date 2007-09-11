module HALog
    # stub class to hold as a default any message that isn't parsed by one of the more
    # important Log Message classes.
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