require 'halog/evil_custom_statement'


module HALog
  class LogEntryStatement < EvilCustomStatement
    TABLE  = "log_entries"
    FIELDS = [ %w[ import_id            bind_int   ],
               %w[ iso_time             bind_text  ],
               %w[ date                 bind_text  ],
               %w[ hostname             bind_text  ],
               %w[ process              bind_text  ],
               %w[ pid                  bind_int   ],
               %w[ raw_message          bind_text  ],
    ].freeze
  end
end
