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
  end
end
