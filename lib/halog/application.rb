require 'optparse'
require 'ostruct'
require 'halog'

module HALog
    class Application
        
        attr_reader :options
        
        def initialize(argv = [])
            argv ||= []

            @options        = default_options
            @parsed_options = ::OpenStruct.new
            @parser         = option_parser
            @error_message  = nil

            begin
                @parser.parse!(argv)
            rescue ::OptionParser::ParseError => pe
                msg = ["#{@parser.program_name}: #{pe}",
                        "Try `#{@parser.program_name} --help` for more information"]
                @error_message = msg.join("\n")
            end
        end
        
        def default_options
            if @default_options.nil? then
                @default_options                = ::OpenStruct.new
                @default_options.database       = ":memory:"
                @default_options.show_version   = false
                @default_options.show_help      = false
                @default_options.input_file     = nil
                @default_options.incremental    = false
                @default_options.output_file    = nil
                @default_options.cache_file     = nil
                @default_options.report_type    = :none
            end
            return @default_options
        end
        
        def option_parser
            OptionParser.new do |op|
                op.separator ""
                
                op.on("-d", "--database FILE", "Location of the sqlite database to record the information in.") do |db|
                    @parsed_options.database = db
                end
                
                op.on("-h", "--help", "Display this text") do 
                    @parsed_options.show_help = true
                end
            
                op.on("-i", "--input-file FILE", "File to parse.", "  Use '-' to indicate stdin") do |infile|
                    @parsed_options.input_file = infile
                end
                
                op.on("-n", "--incremental", "This is an incremental update to an already existing db") do |i|
                    @parsed_options.incremental = true
                end
                                
                op.on("-o", "--output-file FILE", "Where the output information should be sent.", "  Default: stdout") do |outfile|
                    @parsed_options.output_file = outfile
                end

                op.on("-r", "--report TYPE", Report.types, "Display one of the available report types",
                                        "  #{Report.types.join(',')}") do |report|
                    @parsed_options.report = report
                end
                
                op.on("-V", "--version", "Show version") do 
                    @parsed_options.show_version = true
                end
            end
        end
        
        def merge_options
            options = default_options.marshal_dump
            @parsed_options.marshal_dump.each_pair do |key,value|
                options[key] = value
            end

            @options = OpenStruct.new(options)
        end
        
        # if Version or Help options are set, then output the appropriate information instead of 
        # running the server.
        def error_version_help
            if @parsed_options.show_version then
                $stdout.puts "#{@parser.program_name}: version #{HALog::VERSION}"
                exit 0
            elsif @parsed_options.show_help then
                $stdout.puts @parser.to_s
                exit 0
            elsif @error_message then
                $stderr.puts @error_message
                exit 1
            end
        end
        
        def import_new_data(datastore)
            if @options.input_file then
                input_log_stream = (@options.input_file == "-") ? $stdin : File.open(@options.input_file)
                $stderr.puts "Reading input from #{@options.input_file}"
                datastore.import(input_log_stream,{:incremental => @options.incremental})
                $stderr.puts datastore.perf_report
            end 
        end
        
        def run_report(datastore)
            if @options.report then
                outfile = $stdout
                if @options.output_file then
                    outfile = File.open(@options.output_file,"w+")
                    $stderr.puts "Writing report to #{@options.output_file}"
                end
                outfile.puts Report.run(@options.report).on(datastore).to_s
                outfile.close                
            end
        end
        
        def run
            error_version_help
            merge_options

            DataStore.open(@options.database) do |ds|
                $stderr.puts "Using #{@options.database} database."
                import_new_data(ds)
                run_report(ds)
            end    
        end
    end
end