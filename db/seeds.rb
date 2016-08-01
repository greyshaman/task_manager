# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
users = User.create([
  {email: 'admin@example.com',  password: "Pa55w0rd1Ex4mp1e", password_confirmation: "Pa55w0rd1Ex4mp1e", role: "ADMIN"},
  {email: 'user_1@example.com', password: "Pa55w0rd2Ex4mp1e", password_confirmation: "Pa55w0rd2Ex4mp1e"},
  {email: 'user_2@example.com', password: "Pa55w0rd3Ex4mp1e", password_confirmation: "Pa55w0rd3Ex4mp1e"}
])

tasks = Task.create([
  {name: "Turn the Light",  user_id: users.first.id},
  {name: "Open the Eyes",   user_id: users.first.id},
  {name: "Wisper",          user_id: users.second.id},
  {name: "Sleep",           user_id: users.second.id},
  {name: "sIng",            user_id: users.last.id},
  {name: "dRink",           user_id: users.last.id}
])
