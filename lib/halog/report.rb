require 'halog'

module HALog
    module Report
        class Base
            class << self
                def inherited(sub_class)
                    report_classes[sub_class.name.split("::").last.downcase] = sub_class
                end
            
                def report_classes
                    @report_classes ||= {}
                end
                
                def types
                    report_classes.keys
                end
            
                def run(report)
                    report_classes[report.to_s.downcase].new
                end
            end
        
            def on(data_source)
                self 
            end
        end
        
        def run(report)
            Base.run(report)
        end
        module_function :run
        
        def types
            Base.types
        end
        module_function :types
    end
end

require 'halog/report/error'