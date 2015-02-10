# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveRecord::Base.transaction do
  video = Video.create title: 'drive', description: 'This is a test HLS video'
  VideoFile.create name: 'drive.m3u8', google_disk_id: '0B6SbkWXOHDMKRVhhZ2ZEUTlqLWM', video_id: video.id
  VideoFile.create name: 'pl.m3u8', google_disk_id: '0B6SbkWXOHDMKUy1BX3NzTUpMZm8', video_id: video.id
  VideoFile.create name: '0.ts', google_disk_id: '0B6SbkWXOHDMKbVZNeVBYLXRodFk', video_id: video.id
  VideoFile.create name: '1.ts', google_disk_id: '0B6SbkWXOHDMKQ1dKVF8zMjRwTFU', video_id: video.id
  VideoFile.create name: '2.ts', google_disk_id: '0B6SbkWXOHDMKSHoxQ2hDdGZiS2c', video_id: video.id
  VideoFile.create name: '3.ts', google_disk_id: '0B6SbkWXOHDMKTFZaTDFtbXBVanM', video_id: video.id
  VideoFile.create name: '4.ts', google_disk_id: '0B6SbkWXOHDMKT242aWhCdXU3VkE', video_id: video.id
  VideoFile.create name: '5.ts', google_disk_id: '0B6SbkWXOHDMKd3ZZbXN1V0pyTUE', video_id: video.id
  VideoFile.create name: '6.ts', google_disk_id: '0B6SbkWXOHDMKYUF6Yk5KQ1BZMXc', video_id: video.id
end
