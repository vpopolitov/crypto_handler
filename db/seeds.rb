# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveRecord::Base.transaction do
  video = Video.create title: 'drive', description: 'This is a test HLS video'
  VideoFile.create name: 'drive.m3u8', download_url: 'https://doc-10-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/7ca8o59o90bkln3h7g5b9hie7vhg72vm/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKSzBGdXlDU1p1V1U?e=download&gd=true', video_id: video.id
  VideoFile.create name: 'pl.m3u8', download_url: 'https://doc-04-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/lad6fm5pif9elpcttil8i1peoj8e4unt/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKOG1ocE9fYWNwalE?e=download&gd=true', video_id: video.id
  VideoFile.create name: '0.ts', download_url: 'https://doc-0k-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/s1mb75kdtqblun1spu2qeeb7pagc2t75/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKbVZNeVBYLXRodFk?e=download&gd=true', video_id: video.id
  VideoFile.create name: '1.ts', download_url: 'https://doc-00-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/p3amb04tb81eo8iugj4rtltn6lpuagcg/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKQ1dKVF8zMjRwTFU?e=download&gd=true', video_id: video.id
  VideoFile.create name: '2.ts', download_url: 'https://doc-0s-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/j5l2q0gvjdris6hqs809fdeuactpkmun/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKSHoxQ2hDdGZiS2c?e=download&gd=true', video_id: video.id
  VideoFile.create name: '3.ts', download_url: 'https://doc-08-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/t633276eh2tvvr7qqt7vfit31t6oc76t/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKTFZaTDFtbXBVanM?e=download&gd=true', video_id: video.id
  VideoFile.create name: '4.ts', download_url: 'https://doc-00-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/9jou35rrc10j7iql5h036lvd0418c04r/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKT242aWhCdXU3VkE?e=download&gd=true', video_id: video.id
  VideoFile.create name: '5.ts', download_url: 'https://doc-0c-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/igc5uibu5mvt6jjcs0lv97dadr28aihv/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKd3ZZbXN1V0pyTUE?e=download&gd=true', video_id: video.id
  VideoFile.create name: '6.ts', download_url: 'https://doc-08-a8-docs.googleusercontent.com/docs/securesc/tni8a81s5sf9fnjnbokine0c79qdn8u4/89f08b2oc4tcu6o1f0n4llnfinrj342v/1423519200000/12964748917564398755/18378525677701103795/0B6SbkWXOHDMKYUF6Yk5KQ1BZMXc?e=download&gd=true', video_id: video.id
end
