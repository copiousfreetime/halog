require 'halog/custom_statement'
require 'halog/evil_custom_statement'
module HALog
  class TCPLogMessageStatement < EvilCustomStatement
    TABLE  = "tcp_log_messages"
    FIELDS = [ %w[ import_id            bind_int   ],
               %w[ log_entry_id         bind_int   ],
               %w[ client_address       bind_text  ],
               %w[ client_port          bind_int   ],
               %w[ iso_time             bind_text  ],
               %w[ date                 bind_text  ],
               %w[ frontend             bind_text  ],
               %w[ backend              bind_text  ],
               %w[ queue_time           bind_int   ],
               %w[ connect_time         bind_int   ],
               %w[ total_time           bind_int   ],
               %w[ bytes_read           bind_int   ],
               %w[ termination_state    bind_text  ],
               %w[ active_sessions      bind_int   ],
               %w[ frontend_connections bind_int   ],
               %w[ backend_connections  bind_int   ],
               %w[ server_connections   bind_int   ],
               %w[ server_queue_size    bind_int   ],
               %w[ proxy_queue_size     bind_int   ],
    ].freeze
  end
end

