#!/usr/bin/env ruby
# Marks migration versions as applied so Rails won't try to re-create existing tables.
begin
  conn = ActiveRecord::Base.connection
  %w[20260110 20260110120000].each do |v|
    cnt = conn.select_value("SELECT COUNT(1) FROM schema_migrations WHERE version = '#{v}'").to_i
    if cnt == 0
      conn.execute("INSERT INTO schema_migrations(version) VALUES('#{v}')")
      puts "Inserted migration version #{v}"
    else
      puts "Migration version #{v} already present"
    end
  end
rescue => e
  STDERR.puts "Error: #{e.class}: #{e.message}"
  STDERR.puts e.backtrace.join("\n")
  exit 1
end
