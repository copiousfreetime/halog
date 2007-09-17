module HALog 
    class LogParser
        attr_reader :first_entry_time 
        attr_reader :last_entry_time 
        attr_reader :starting_offset
        attr_reader :byte_count
        attr_reader :entry_count
        attr_reader :error_count
        attr_reader :parse_time

        def initialize()
            @first_entry_time   = nil
            @last_entry_time    = nil
            @starting_offset    = 0
            @byte_count         = 0
            @entry_count        = 0
            @error_count        = 0
            @parse_time         = 0
        end
        
        # parses the io stream yielding each valid LogEntry that is encountered.  Invalid lines
        # are logged to stderr
        def parse(io,options = {})
            io = advance_io(io,options)
            @starting_offset = io.pos
            
            io.each do |line|
                
                @byte_count += line.size
                before_parse = Time.now
                entry = LogEntry.parse(line)
                @parse_time += Time.now - before_parse
                if entry then
                    @first_entry_time ||= entry.time
                    @last_entry_time = entry.time
                    @entry_count += 1  
                                          
                    yield entry
                else
                    @error_count += 1
                    $stderr.puts 
                    $stderr.puts "Failure to parse line : #{line.rstrip}"
                end
                
                if @entry_count % 1000 == 0 then
                    $stderr.print "parsing: #{@entry_count}\r"
                    $stderr.flush
                end
                
            end # io.each
            $stderr.puts "parsed: #{@entry_count}    " # extra space to blank out potential other characters.
            return self
        end
        
        # advance the IO forward if it looks like this logfile has already been parsed.
        # advancing the IO only works on actual files.  IO that comes from STDIN 
        def advance_io(io,options)
            return io if options.size == 0

            %w[ byte_count starting_offset first_entry_time last_entry_time import_ended_on].each do |c| 
                raise "Missing option '#{c}' from LogParser options." if not options.keys.include?(c)
            end

            # if the file as a filesize that is less than the offset we would seek to, assume that the 
            # file should be scanned from the beginning.
            seek_to = options['starting_offset'] + options['byte_count']
            return io if io.stat.size < seek_to

            # now we assume that we are using the same file as before so seek to the appropriate location
            io.seek(seek_to,IO::SEEK_SET)
            
            return io
        end
    end    
end