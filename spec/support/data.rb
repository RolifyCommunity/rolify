# Users
[ User, Admin::User, Customer, Admin::Customer ].each do |user|
  user.destroy_all
  
  user.create(:login => "admin")
  user.create(:login => "moderator")
  user.create(:login => "god")
  user.create(:login => "zombie")
end

# Roles
[ Role, Admin::Role, Privilege, Admin::Privilege ].each do |role|
  role.destroy_all
end

# Resources
Forum.create(:name => "forum 1")
Forum.create(:name => "forum 2")
Forum.create(:name => "forum 3")

Group.create(:name => "group 1")
Group.create(:name => "group 2")
