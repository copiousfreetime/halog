module HALog
    # permanent storage for the results of parsing the logfile.
    # this is backed by a SQLite 3 database with a few tables
    class DataStore
        
        
        def initialize(database = ":memory:", options = {})
            @incremental = options[:incremental] || false
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