namespace :access_code do
  desc 'Generate random access code for each video'
  task generator: :environment do
    Video.all.each do |video|
      video.access_code = (('a'..'z').to_a + (0..9).to_a).shuffle[0..5].join
      video.save!
    end
  end
end