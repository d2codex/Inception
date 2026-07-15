# this script is responsible for:
#	reading secrets
#	initializing the databse if needed
#	creating users/databases
#	starting the MariaDB daemon

#!/bin/bash

# MariaDB initialization logic goes here

# Replace the current shell process with the command passed as arguments.
# This makes the application (mysqld) become PID 1 inside the container,
# allowing Docker to properly track the main process and handle signals
# such as SIGTERM for clean shutdown.
exec "$@"
