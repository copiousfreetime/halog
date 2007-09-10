module HALog
    class HTTPLogMessage
        def initialize(line)
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