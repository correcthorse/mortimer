desc "Update the old, unencrypted notes to new, encrypted notes."
task :update_notes => :environment do
  @entries_updated = []

  Entry.find(:all).each do |entry|
    if entry.respond_to?(:notes) && !entry.notes.blank?
      entry.description = entry.notes
      if entry.save
        @entries_updated << entry
        Rails.logger.warn("Note Updater: Entry ##{entry.id} updated.")
      end
    end
  end

  puts "#{@entries_updated.length} entries updated. See #{Rails.env}.log for more details."
  Rails.logger.flush
end
