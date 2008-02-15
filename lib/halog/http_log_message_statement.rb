require 'halog/evil_custom_statement'
require 'halog/tcp_log_message_statement'

module HALog
  class HTTPLogMessageStatement < EvilCustomStatement
    TABLE  = "http_log_messages"
    FIELDS = [ %w[ import_id            bind_int   ],
               %w[ log_entry_id         bind_int   ],
               %w[ client_address       bind_text  ],
               %w[ client_port          bind_int   ],
               %w[ iso_time             bind_text  ],
               %w[ date                 bind_text  ],
               %w[ frontend             bind_text  ],
               %w[ backend              bind_text  ],
               %w[ server               bind_text  ],
               %w[ request_time         bind_int   ],
               %w[ queue_time           bind_int   ],
               %w[ connect_time         bind_int   ],
               %w[ response_time        bind_int   ],
               %w[ total_time           bind_int   ],
               %w[ http_status          bind_int   ],
               %w[ bytes_read           bind_int   ],
               %w[ request_cookie       bind_text  ],
               %w[ response_cookie      bind_text  ],
               %w[ termination_state    bind_text  ],
               %w[ active_sessions      bind_int   ],
               %w[ frontend_connections bind_int   ],
               %w[ backend_connections  bind_int   ],
               %w[ server_connections   bind_int   ],
               %w[ incoming_queue_size  bind_int   ],
               %w[ server_queue_size    bind_int   ],
               %w[ request_headers      bind_text  ],
               %w[ response_headers     bind_text  ],
               %w[ http_request         bind_text  ],
    ].freeze  
  end
end
