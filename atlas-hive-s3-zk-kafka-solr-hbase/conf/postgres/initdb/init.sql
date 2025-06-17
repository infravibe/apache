-- Already created by env vars:
--   User: postgres (superuser)
--   DB: postgres (owned by postgres)

-- Create additional users
CREATE USER hive WITH PASSWORD 'password';
CREATE USER ranger WITH PASSWORD 'rangerpass';

-- Create more databases
CREATE DATABASE metastore_db OWNER hive;
CREATE DATABASE ranger OWNER ranger;
