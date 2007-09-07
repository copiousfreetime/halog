require 'ostruct'
require 'halog'

module HALog
    class Application
        def initialize(argv = [])
            argv ||= []

            set_io

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
                @default_options.show_version   = false
                @default_options.show_help      = false
                @default_options.input_file     = nil
                @default_options.output_file    = nil
                @default_options.syslog_regex   = /\A(\w+\s+\d+\s+\d\d:\d\d:\d\d\s+\S+)/
                @default_options.cache_file     = nil
                @default_options.report_type    = nil
            end
            return @default_options
        end
        
        def option_parser
            OptionParser.new do |op|
                op.separator ""
                
                op.on("-d", "--database", "Location of the sqlite database to record the information in.") do |db|
                    @parsed_options.database = db
                end
                
                op.on("-h", "--help", "Display this text") do 
                    @parsed_options.show_help = true
                end
                
                op.on("-i", "--input-file FILE", "File to parse, default is stdin.") do |infile|
                    @parsed_options.input_file = infile
                end
                
                op.on("-o", "--output-file FILE", "Where the output information should be sent.", "Default is stdout") do |outfile|
                    @parsed_options.output_file = outfile
                end

                op.on("-r", "--report TYPE", "Display one of the available report types") do |report|
                    @parsed_options.report = report
                end
                
                op.on("-s", "--syslog-regex REGEX", "Regular expression to match the syslog data portion of the entry") do |r|
                    @parsed_options.syslog_regex = Regexp.new(r)
                end
                
                op.on("-v", "--version", "Show version") do 
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
                @stdout.puts "#{@parser.program_name}: version #{Heel::VERSION}"
                exit 0
            elsif @parsed_options.show_help then
                @stdout.puts @parser.to_s
                exit 0
            elsif @error_message then
                @stdout.puts @error_message
                exit 1
            end
        end
        
        def run
            error_version_help
            merge_options
            
            
            infile = @options.input_file ? File.open(@options.input_file) : $stdin
            
            ds = DataStore.connect(@options.database)
            ds.import(infile)
            if @options.report then
                outfile = @options.output_file ? File.open(@options.output_file,"w+") : $stdout
                outfile.write Report.run_type(@options.report).on(ds).to_s
                outfile.close
            end
        end
    end
end