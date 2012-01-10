# Users
[User, Muser].each do |user|
  user.create(:login => "admin")
  user.create(:login => "moderator")
  user.create(:login => "god")
  user.create(:login => "zombie")
end

[Customer, Mcustomer].each do |customer|
  customer.create(:login => "admin")
  customer.create(:login => "moderator")
  customer.create(:login => "god")
  customer.create(:login => "zombie")
end

# Resources
[Forum, Mforum].each do |forum|
  forum.create(:name => "forum 1")
  forum.create(:name => "forum 2")
  forum.create(:name => "forum 3")
end
[Group, Mgroup].each do |group|
  group.create(:name => "group 1")
  group.create(:name => "group 2")
end