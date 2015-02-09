# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveRecord::Base.transaction do
  video = Video.create title: 'drive', description: 'This is a test HLS video'
  VideoFile.create name: 'drive.m3u8', download_url: 'https://doc-0o-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/qgav17rvtpv6cnfnk8i674d88vouuat4/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKSzBGdXlDU1p1V1U?e=download&gd=true', video_id: video.id
  VideoFile.create name: 'pl.m3u8', download_url: 'https://doc-0s-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/1qtuiq32hoe1ohk8esv98pt4g5953spg/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKOG1ocE9fYWNwalE?e=download&gd=true', video_id: video.id
  VideoFile.create name: '0.ts', download_url: 'https://doc-14-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/vstjut8p8t0kp0gph6ci6ovdqqg52ril/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKbVZNeVBYLXRodFk?e=download&gd=true', video_id: video.id
  VideoFile.create name: '1.ts', download_url: 'https://doc-08-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/8gf79jlpmj6esnvsq0l19igbo2tv2mkb/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKQ1dKVF8zMjRwTFU?e=download&gd=true', video_id: video.id
  VideoFile.create name: '2.ts', download_url: 'https://doc-0g-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/jgudkudoabe7b2di61t6a6bufjk55ble/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKSHoxQ2hDdGZiS2c?e=download&gd=true', video_id: video.id
  VideoFile.create name: '3.ts', download_url: 'https://doc-0g-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/k8pv9p57p4dngg71qqpb4qp0b49vq5mp/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKTFZaTDFtbXBVanM?e=download&gd=true', video_id: video.id
  VideoFile.create name: '4.ts', download_url: 'https://doc-04-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/o5kjo6d1jnm9mfg37213eua60u1t02qv/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKT242aWhCdXU3VkE?e=download&gd=true', video_id: video.id
  VideoFile.create name: '5.ts', download_url: 'https://doc-04-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/e256vtd6n46pdl08h66a85b3ukue4hn6/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKd3ZZbXN1V0pyTUE?e=download&gd=true', video_id: video.id
  VideoFile.create name: '6.ts', download_url: 'https://doc-10-a8-docs.googleusercontent.com/docs/securesc/tjgtdlt6bpukurnemqggjj4ieknm11uh/2fr0kth8kem592pjme52ihp3n9d8v7ur/1423512000000/12964748917564398755/12964748917564398755/0B6SbkWXOHDMKYUF6Yk5KQ1BZMXc?e=download&gd=true', video_id: video.id
end
