module HALog
    module Report
        class Error < Base
            def on(datastore)
                self
            end
            def to_s
                "This is the error report\n"
            end
        end
    end
end
        