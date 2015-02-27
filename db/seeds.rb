# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

stitching   = Category.create title: 'Кройка и шитье'
needle_work = Category.create title: 'Вышивание'

Video.create title: 'Урок 1', category_id: stitching.id
Video.create title: 'Урок 2', category_id: stitching.id
Video.create title: 'Урок 3', category_id: stitching.id
Video.create title: 'Урок 4', category_id: stitching.id

Video.create title: 'Урок 1', category_id: needle_work.id
Video.create title: 'Урок 2', category_id: needle_work.id
Video.create title: 'Урок 3', category_id: needle_work.id
Video.create title: 'Урок 4', category_id: needle_work.id
Video.create title: 'Урок 5', category_id: needle_work.id
