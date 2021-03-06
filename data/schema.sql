-- holds meta informationa about each import run.
CREATE TABLE imports (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    import_started_on   TIMESTAMP,  -- timestamp of when the run was started
    import_ended_on     TIMESTAMP,  -- timestamp of when the run was finished
    import_date         DATE,       -- inserted with trigger
    first_entry_time    TIMESTAMP,  -- timestamp in the first log entry processed
    last_entry_time     TIMESTAMP,  -- timestamp in the last log entry processed
    starting_offset     INTEGER,
    byte_count          INTEGER,
    entry_count         INTEGER,    -- line count of rows entered into the database
    error_count         INTEGER     -- count of error lines skipped from input
    )
;
CREATE INDEX imports_import_date_idx ON imports(import_date);
CREATE TRIGGER imports_date_trigger AFTER INSERT ON imports
    FOR EACH ROW
    BEGIN
        UPDATE imports SET import_date = date(new.import_started_on) WHERE id = new.id
        ;
    END
;
    
-- BATCH END


    
-- The basic information from every line of the log file
CREATE TABLE log_entries (
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,
    import_id               INTEGER NOT NULL,
    iso_time                TIMESTAMP NOT NULL,
    date                    DATE NOT NULL,
    hostname                TEXT NOT NULL,
    process                 TEXT NOT NULL,
    pid                     INTEGER,
    raw_message             TEXT NOT NULL
    )
;
    
CREATE INDEX log_entries_import_id_idx ON log_entries(import_id);
CREATE INDEX log_entries_date_idx ON log_entries(date);
    
-- The messages that are  TCP logs
CREATE TABLE tcp_log_messages (
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,
    import_id               INTEGER NOT NULL,
    log_entry_id            INTEGER NOT NULL,
    client_address          TEXT NOT NULL,
    client_port             INTEGER NOT NULL,
    
    iso_time                TIMESTAMP NOT NULL,
    date                    DATE NOT NULL,
    
    frontend                TEXT NOT NULL,
    backend                 TEXT NOT NULL,
    
    queue_time              INTEGER NOT NULL, -- microseconds
    connect_time            INTEGER NOT NULL, -- microseconds
    total_time              INTEGER NOT NULL, -- microseconds
    
    bytes_read              INTEGER NOT NULL,
    
    termination_state       TEXT NOT NULL,
    
    active_sessions         INTEGER NOT NULL,
    frontend_connections    INTEGER NOT NULL, 
    backend_connections     INTEGER NOT NULL,
    server_connections      INTEGER NOT NULL,
    
    server_queue_size       INTEGER NOT NULL,
    proxy_queue_size        INTEGER NOT NULL
    )
;
CREATE INDEX tcp_log_messages_import_id_idx ON tcp_log_messages(import_id);
CREATE INDEX tcp_log_messages_log_entry_id_idx ON tcp_log_messages(log_entry_id);
CREATE INDEX tcp_log_messages_date_idx ON tcp_log_messages(date);
CREATE INDEX tcp_log_messages_frontend_idx ON tcp_log_messages(frontend);
CREATE INDEX tcp_log_messages_backend_idx ON tcp_log_messages(backend);
    
-- The messages that are HTTP Logs  
CREATE TABLE http_log_messages (
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,
    import_id               INTEGER NOT NULL,
    log_entry_id            INTEGER NOT NULL,
    client_address          TEXT NOT NULL,
    client_port             INTEGER NOT NULL,
    
    iso_time                TIMESTAMP NOT NULL,
    date                    DATE NOT NULL,
    
    frontend                TEXT NOT NULL,
    backend                 TEXT NOT NULL,
    server                  TEXT NOT NULL,
    
    request_time            INTEGER NOT NULL, -- microseconds
    queue_time              INTEGER NOT NULL, -- microseconds
    connect_time            INTEGER NOT NULL, -- microseconds
    response_time           INTEGER NOT NULL, -- microseconds
    total_time              INTEGER NOT NULL, -- microseconds
    
    http_status             INTEGER NOT NULL,
    bytes_read              INTEGER NOT NULL,
    
    request_cookie          TEXT,
    response_cookie         TEXT,
    
    termination_state       TEXT NOT NULL,
    
    active_sessions         INTEGER NOT NULL,
    frontend_connections    INTEGER NOT NULL, 
    backend_connections     INTEGER NOT NULL,
    server_connections      INTEGER NOT NULL,
    
    incoming_queue_size     INTEGER NOT NULL,
    server_queue_size       INTEGER NOT NULL,
    
    request_headers         TEXT,
    response_headers        TEXT,
    
    http_request            TEXT NOT NULL
        )
;

CREATE INDEX http_log_messages_import_id_idx ON http_log_messages(import_id);
CREATE INDEX http_log_messages_log_entry_id_idx ON http_log_messages(log_entry_id);
CREATE INDEX http_log_messages_date_idx ON http_log_messages(date);
CREATE INDEX http_log_messages_frontend_idx ON http_log_messages(frontend);
CREATE INDEX http_log_messages_backend_idx ON http_log_messages(backend);
CREATE INDEX http_log_messages_server_idx ON http_log_messages(server);
CREATE INDEX http_log_messages_status_idx ON http_log_messages(http_status);
