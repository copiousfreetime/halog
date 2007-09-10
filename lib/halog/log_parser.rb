module HALog
    
    class LogParser
        def initialize()
        end
        
        def parse(io)
        end
        
        class << self
            def parse(io)
                LogParser.new.parse(io)
            end
        end
    end
    
end