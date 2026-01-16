```markdown
# Migrate from SQLite3 to PostgreSQL (LuxeCart)

This guide shows exact commands to convert the Rails app from SQLite to PostgreSQL and migrate data.

Important: BACK UP your sqlite file before doing anything:
cp storage/development.sqlite3 storage/development.sqlite3.bak

## 1) Install PostgreSQL and pgloader

### Ubuntu / WSL
sudo apt update
sudo apt install -y postgresql postgresql-contrib libpq-dev pgloader
sudo service postgresql start

### macOS (Homebrew)
brew install postgresql pgloader
brew services start postgresql

## 2) Create a Postgres role and DBs

# Option using postgres user (Linux/WSL)
sudo -u postgres psql
-- then inside psql:
CREATE ROLE luxecart_user WITH LOGIN PASSWORD 'luxecart_pass';
CREATE DATABASE luxecart_development OWNER luxecart_user;
CREATE DATABASE luxecart_test OWNER luxecart_user;
\q

# Or using createuser / createdb:
createuser -P luxecart_user   # set password luxecart_pass
createdb -O luxecart_user luxecart_development
createdb -O luxecart_user luxecart_test

## 3) Update Gemfile and bundle install
- Replace gem "sqlite3" with gem "pg", "~> 1.4"
- Then run:
bundle install

If you see errors installing pg, ensure libpq-dev (Linux) or postgresql (macOS) is installed.

## 4) Set environment variables (locally)
export DB_USERNAME=luxecart_user
export DB_PASSWORD=luxecart_pass
export DB_HOST=localhost
export DB_NAME_DEVELOPMENT=luxecart_development
export DB_NAME_TEST=luxecart_test

(Consider adding these to a .env file when using dotenv-rails.)

## 5) Create and migrate DB structure in Postgres
bundle exec rails db:create
bundle exec rails db:migrate

Verify:
bundle exec rails c
> ActiveRecord::Base.connection.adapter_name   # should show "PostgreSQL"
> ActiveRecord::Base.connection_db_config.database

## 6) Migrate data from SQLite to Postgres

### Recommended: pgloader
Run the helper script:
chmod +x scripts/migrate_sqlite_to_pg.sh
./scripts/migrate_sqlite_to_pg.sh ./storage/development.sqlite3 postgresql://luxecart_user:luxecart_pass@localhost/luxecart_development

OR run pgloader directly:
pgloader sqlite:///absolute/path/to/storage/development.sqlite3 postgresql://luxecart_user:luxecart_pass@localhost/luxecart_development

pgloader will convert schema and copy rows. After successful run, verify record counts in Rails console.

### Fallback: CSV export/import (if pgloader isn't available)
1. Export tables to CSV:
mkdir -p tmp/db_export
bundle exec rails runner 'require "csv"; ActiveRecord::Base.connection.tables.each { |t| next if t == "schema_migrations"; cols = ActiveRecord::Base.connection.columns(t).map(&:name); CSV.open("tmp/db_export/#{t}.csv","w") { |csv| csv << cols; ActiveRecord::Base.connection.execute("SELECT * FROM #{t}").each { |row| csv << cols.map { |c| row[c] } } } }'

2. Import CSVs into Postgres (psql):
psql -h localhost -U luxecart_user -d luxecart_development
-- in psql:
\copy users FROM 'tmp/db_export/users.csv' WITH CSV HEADER;
-- repeat for other tables
\q

3. Reset serial sequences (important):
psql -h localhost -U luxecart_user -d luxecart_development -c "SELECT setval(pg_get_serial_sequence('users','id'), coalesce(max(id),1), true) FROM users;"

## 7) Verify the app
- Run rails console and compare counts:
bundle exec rails c
User.count
Product.count

- Start the server and test key flows:
bundle exec rails server
Visit http://localhost:3000 and test login/create items etc.

## 8) Production notes
- Set DATABASE_URL or DB_* environment variables on your production host.
- Run migrations in production: RAILS_ENV=production bundle exec rails db:migrate
- Use managed Postgres (Heroku, Render, RDS) for best reliability.

## 9) Rollback plan
- Keep your sqlite backup: storage/development.sqlite3.bak
- Keep a git branch containing the pre-change Gemfile/database.yml to revert if needed.

If you'd like, I can create a branch and open a PR containing these changes (Gemfile, database.yml, scripts, docs). If you want that, tell me the base branch name (default: main).
```