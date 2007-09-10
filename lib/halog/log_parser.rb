module HALog 
    class LogParser        
        # parses the io stream yielding each valid LogEntry that is encountered.  Invalid lines
        # are logged to stderr
        def parse(io)
            io.each do |line|
                entry = LogEntry.parse(line)
                if entry then
                    yield entry
                else
                    $stderr.puts "Failure to parse line : #{line.rstrip}"
                end
            end            
        end
        
        class << self
            def parse(io)
                LogParser.new.parse(io)
            end
        end
    end
    
end