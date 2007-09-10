module HALog
    class DataStore
        def initialize(database = ":memory:")
        end
        
        class << self
            def open(location)
                DataStore.new(location)
            end
        end

        def import(io)
            LogParser.new.parse(io) do |entry|
            end
        end
    end
end