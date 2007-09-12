-- holds meta informationa about each import run.
CREATE TABLE imports (
	id 						INTEGER PRIMARY KEY,
	import_started_on		TIMESTAMP,	-- timestamp of when the run was started
	import_ended_on			TIMESTAMP, 	-- timestamp of when the run was finished
	entry_started_on		TIMESTAMP,  -- timestamp in the first log entry processed
	entry_ended_on			TIMESTAMP,	-- timestamp in the last log entry processed
	entry_count				INTEGER, 	-- line count of rows entered into the database
	start_offset			INTEGER, 	-- byte offset in the file of the starting point of the run
	end_offset				INTEGER, 	-- byte offset in the file of the ending pont of the run.
	);
	
-- The basic information from every line of the log file
CREATE TABLE log_entries (
	id						INTEGER PRIMARY KEY,
	import_id				INTEGER NOT NULL,
	recorded_on				TIMESTAMP NOT NULL,
	hostname				TEXT NOT NULL,
	process					TEXT NOT NULL,
	pid						INTEGER,
	message					TEXT NOT NULL
	);
	
-- The messages that are  TCP logs
CREATE TABLE tcp_log_messages (
	id						INTEGER PRIMARY KEY,
	log_entry_id			INTEGER NOT NULL,
	client_address			TEXT NOT NULL,
	client_port				INTEGER NOT NULL,
	recorded_on				TIMESTAMP NOT NULL,
	frontend				TEXT NOT NULL,
	backend					TEXT NOT NULL,
	queue_time				INTEGER NOT NULL, -- microseconds
	connect_time			INTEGER NOT NULL, -- microseconds
	total_time				INTEGER NOT NULL, -- microseconds
	bytes_read				INTEGER NOT NULL,
	termination_state		TEXT NOT NULL,
	active_sessions 		INTEGER NOT NULL,
	frontend_connections	INTEGER NOT NULL, 
	backend_connections 	INTEGER NOT NULL,
	server_connections 		INTEGER NOT NULL,
	server_queue_size		INTEGER NOT NULL,
	proxy_queue_size		INTEGER NOT NULL
	);
	
-- The messages that are HTTP Logs	
CREATE TABLE tcp_log_messages (
		id						INTEGER PRIMARY KEY,
		log_entry_id			INTEGER NOT NULL,
		client_address			TEXT NOT NULL,
		client_port				INTEGER NOT NULL,
		recorded_on				TIMESTAMP NOT NULL,
		frontend				TEXT NOT NULL,
		backend					TEXT NOT NULL,
		request_time			INTEGER NOT NULL, -- microseconds
		queue_time				INTEGER NOT NULL, -- microseconds
		connect_time			INTEGER NOT NULL, -- microseconds
		response_time			INTEGER NOT NULL, -- microseconds
		total_time				INTEGER NOT NULL, -- microseconds
		http_status				INTEGER NOT NULL,
		bytes_read				INTEGER NOT NULL,
		request_cookie			TEXT,
		response_cookie			TEXT,
		termination_state		TEXT NOT NULL,
		active_sessions 		INTEGER NOT NULL,
		frontend_connections	INTEGER NOT NULL, 
		backend_connections 	INTEGER NOT NULL,
		server_connections 		INTEGER NOT NULL,
		incoming_queue_size		INTEGER NOT NULL,
		server_queue_size		INTEGER NOT NULL,
		request_headers			TEXT,
		response_headers		TEXT,
		http_request			TEXT NOT NULL
		);
