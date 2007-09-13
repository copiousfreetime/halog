module HALog 
    class LogParser
        attr_reader :first_entry_time 
        attr_reader :last_entry_time 
        attr_reader :starting_offset
        attr_reader :byte_count
        attr_reader :entry_count
        attr_reader :error_count

        def initialize()
            @first_entry_time   = nil
            @last_entry_time    = nil
            @starting_offset    = 0
            @byte_count         = 0
            @entry_count        = 0
            @error_count        = 0
        end
        
        # parses the io stream yielding each valid LogEntry that is encountered.  Invalid lines
        # are logged to stderr
        def parse(io,options = {})
            
            # TODO : move forward to the appropriate place based on input options.
            
            io.each do |line|
                
                @byte_count += line.size
            
                if entry = LogEntry.parse(line) then
                    @first_entry_time ||= entry.time
                    @last_entry_time = entry.time
                    @entry_count += 1                        
                    yield entry
                else
                    @error_count += 1
                    $stderr.puts "Failure to parse line : #{line.rstrip}"
                end
                
                if @entry_count % 1000 == 0 then
                    $stderr.print "."
                    $stderr.flush
                end
                
            end # io.each
            return self
        end
    end    
end