require 'halog/utils'
module HALog 
  class LogParser

    include Util

    attr_reader :first_entry_time 
    attr_reader :last_entry_time 
    attr_reader :starting_offset
    attr_reader :byte_count
    attr_reader :entry_count
    attr_reader :error_count
    attr_reader :parse_time

    SAMPLE_EVERY = 100
    REPORT_EVERY = 2000

    def initialize()
      @first_entry_time   = nil
      @last_entry_time    = nil
      @starting_offset    = 0
      @byte_count         = 0
      @entry_count        = 0
      @error_count        = 0
      @parse_time         = 0
      @start_time         = 0
    end

    # parses the io stream yielding each valid LogEntry that is encountered.  Invalid lines
    # are logged to stderr
    def parse(io,options = {})
      io = advance_io(io,options)
      @starting_offset = io.pos
      total_bytes      = io.stat.size - @starting_offset
      @start_time       = Time.now

      $stderr.puts
      $stderr.puts status_header

      io.each do |line|

        @byte_count += line.size

        # sample the time it takes every N rows
        if @entry_count % SAMPLE_EVERY == 0 then
          before_parse = Time.now
          entry = LogEntry.parse(line) 
          @parse_time += ( (Time.now - before_parse) * SAMPLE_EVERY )
        else
          entry = LogEntry.parse(line) 
        end

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

        if @entry_count % REPORT_EVERY == 0 then 
          $stderr.print "#{status_output(io.pos,total_bytes)}\r"
        end

      end # io.each
      $stderr.puts status_output(io.pos,total_bytes)
      $stderr.puts

      return self
    end

    def status_header   
      output = StringIO.new
      header = [
                      "Lines".rjust(10), 
                      "Row rate".rjust(10),
                      "Byte rate".rjust(12),
                      "Progress".rjust(20),
                      "% Done".rjust(8),
                      "Timer".rjust(10),
                      "Time left".rjust(10)
      ].join(' ')
      output.puts header
      output.print "-" * header.size
      output.string
    end

    def status_output(current_pos,total_bytes)
      completed_bytes   = current_pos - @starting_offset
      elapsed_time      = Time.now - @start_time
      bytes_left        = total_bytes - completed_bytes
      byte_rate         = completed_bytes.to_f / elapsed_time
      time_left         = bytes_left / byte_rate
      rps               = @entry_count / elapsed_time
      bps               = completed_bytes / elapsed_time
      percent_complete  = (completed_bytes.to_f / total_bytes) * 100.0

      status = [
              "#{@entry_count}".rjust(10),
              "#{"%.0f" % rps} rps".rjust(10),
              "#{num_to_bytes(bps)}/s".rjust(12),
              "#{num_to_bytes(completed_bytes)}/#{num_to_bytes(total_bytes)}".rjust(20),
              "#{"%.2f" % percent_complete}%".rjust(8),
                hms_from_seconds(elapsed_time).rjust(10),
                hms_from_seconds(time_left).rjust(10)
      ]

      status.join(' ')
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
        $stderr.puts "Looks like log file has been rotated, starting from the beginning."
        return io if io.stat.size < seek_to
      end

      # now we assume that we are using the same file as before so seek to the appropriate location
      $stderr.puts "Jumping to offset #{seek_to} in file of size #{io.stat.size}."
      io.seek(seek_to,IO::SEEK_SET)

      return io
    end
  end    
end
