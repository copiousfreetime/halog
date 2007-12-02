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
            @parse_time         = Benchmark::Tms.new
        end
        
        # parses the io stream yielding each valid LogEntry that is encountered.  Invalid lines
        # are logged to stderr
        def parse(io,options = {})
            io = advance_io(io,options)
            @starting_offset = io.pos
            total_bytes      = io.stat.size - @starting_offset
            start_time       = Time.now
            
            io.each do |line|
                
                @byte_count += line.size
                # before_parse = Time.now
                entry = nil
                b = Benchmark.measure { entry = LogEntry.parse(line) }
                # @parse_time += Time.now - before_parse
                @parse_time += b
                if entry then
                    @first_entry_time ||= entry.time
                    @last_entry_time = entry.time
                    @entry_count += 1  
                                          
                    yield entry if block_given?
                else
                    @error_count += 1
                    $stderr.puts 
                    $stderr.puts "Failure to parse line : #{line.rstrip}"
                end
                
                if @entry_count % 1000 == 0 then
                    current_pos       = io.pos
                    completed_bytes   = current_pos - @starting_offset
                    elapsed_time      = Time.now - start_time
                    bytes_left        = total_bytes - completed_bytes
                    byte_rate         = completed_bytes.to_f / elapsed_time
                    time_left         = bytes_left / byte_rate
                    rps               = @entry_count / elapsed_time
                    bps               = completed_bytes / elapsed_time
                    
                    status = [
                        "parsed lines: #{@entry_count} (#{"%.2f" % rps} rps)",
                        "byte count: #{num_to_bytes(completed_bytes)}/#{num_to_bytes(bytes_left)} (#{num_to_bytes(bps)}/s)",
                        "time elapsed: #{hms_from_seconds(elapsed_time)}",
                        "time left: #{hms_from_seconds(time_left)}"
                        ]
                    
                    $stderr.print "%-40s %-40s %-30s %-25s #{' '*10}\r" % status
                    $stderr.flush
                end
                
            end # io.each
            $stderr.puts
            $stderr.puts "Done. parsed lines: #{@entry_count}"
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
            if io.stat.size < seek_to then
                $stderr.print "Looks like file has been rotated, starting from the beginning."
                return io if io.stat.size < seek_to
            end

            # now we assume that we are using the same file as before so seek to the appropriate location
            $stderr.print "Jumping to offset #{seek_to} in file of size #{io.stat.size}."
            io.seek(seek_to,IO::SEEK_SET)
            
            return io
        end
        
        
        # essentially this is strfbytes from facets
        def num_to_bytes(num,fmt="%.2f")
           case
            when num < 1024
              "#{num} bytes"
            when num < 1024**2
              "#{fmt % (num.to_f / 1024)} KB"
            when num < 1024**3
              "#{fmt % (num.to_f / 1024**2)} MB"
            when num < 1024**4
              "#{fmt % (num.to_f / 1024**3)} GB"
            when num < 1024**5
              "#{fmt % (num.to_f / 1024**4)} TB"
            else
              "#{num} bytes"
            end
        end
        
        def hms_from_seconds(seconds)
            hms = [0, 0, 0]
            hms[2] = seconds % 60
            min_left = (seconds - hms[2]) / 60
            
            hms[1]    = min_left % 60
            hms[0]    = (min_left - hms[1]) / 60
            return "%02d:%02d:%02d" % hms
        end

    end    
end