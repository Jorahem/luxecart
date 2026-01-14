#!/usr/bin/env ruby
# Marks migration version '20260110' as applied by inserting into schema_migrations if missing.
# Run with: bin/rails runner script/mark_migration_20260110.rb

begin
  conn = ActiveRecord::Base.connection
  count = conn.select_value("SELECT COUNT(1) FROM schema_migrations WHERE version = '20260110'").to_i
  if count == 0
    conn.execute("INSERT INTO schema_migrations(version) VALUES('20260110')")
    puts "Inserted migration version 20260110 into schema_migrations"
  else
    puts "Migration version 20260110 already present in schema_migrations"
  end
rescue => e
  STDERR.puts "Error: #{e.class}: #{e.message}"
  STDERR.puts e.backtrace.join("\n")
  exit 1
end