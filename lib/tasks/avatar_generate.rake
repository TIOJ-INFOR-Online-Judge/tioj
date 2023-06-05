namespace :avatar do
  desc "Generate missing avatar"
  task generate_missing: :environment do |task, args|
    User.where(avatar: nil).each do |x|
      Tempfile.create(['', '.png']) do |tmpfile|
        Visicon.new(SecureRandom.random_bytes(16), '', 128).draw_image.write(tmpfile.path)
        x.avatar = tmpfile
        x.save!
      end
    end
  end
end
