namespace :old_feedback do
  desc "Delete feedback older than 2 years"
  task delete: :environment do
    scope = AnonymousContact.where(created_at: ...2.years.ago)
    total = scope.count

    puts "Deleting #{total} anonymous contacts (feedback) older than 2 years"

    batch_size = 100_000
    start = Time.zone.now

    scope.in_batches(of: batch_size).each_with_index do |batch, index|
      batch.delete_all

      elapsed = (Time.zone.now - start).round(1)
      deleted_count = [(index + 1) * batch_size, total].min
      deleted_percent = ((deleted_count / total.to_f) * 100).round(1)

      puts "Deleted #{deleted_count}/#{total} (#{deleted_percent}%) in #{elapsed}s"
    end

    puts "#{scope.reload.count} anonymous contacts (feedback) older than 2 years remaining"
    puts "Run old_feedback:vacuum to shrink the table on disk"
  end

  desc "Shrink anonymous_contacts on disk after old_feedback:delete"
  task vacuum: :environment do
    connection = ActiveRecord::Base.connection
    heap_size_query = "SELECT pg_size_pretty(pg_relation_size('anonymous_contacts'))"

    puts "Shrinking anonymous_contacts (#{connection.select_value(heap_size_query)}), " \
         "blocking all reads and writes until it finishes"

    started = Time.zone.now
    connection.execute("SET statement_timeout = 0")
    connection.execute("VACUUM (FULL, ANALYZE) anonymous_contacts")
    elapsed = (Time.zone.now - started).round(1)

    puts "Shrank to #{connection.select_value(heap_size_query)}, blocked for #{elapsed}s"
  end
end
