module HALog
    class Version
        MAJOR   = 0
        MINOR   = 1
        BUILD   = 5

        class << self
            def to_a
                [MAJOR, MINOR, BUILD]
            end

            def to_s
                to_a.join(".")
            end
        end
    end
    VERSION = Version.to_s
end
