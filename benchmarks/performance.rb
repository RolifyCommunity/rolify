require 'bundler/setup'

Bundler.require(:default, :test)
require 'rolify'
require 'benchmark'

require './spec/spec_helper'

def seed_roles(n, resources)
  resource = resources[rand(resources.count)]
  resource_type = resource.is_a?(Class) ? resource.to_s : resource.class.to_s if resource
  resource_id = resource.is_a?(Class) ? nil : resource.id if resource
  n.times { Role.create(:name => "role_#{rand(9999999)}", :resource_type => resource_type, :resource_id => resource_id) }
end

def bench_it(user, n, roles)
  Benchmark.bmbm do |x| 
    requested_roles = []
    2.times { requested_roles += roles  }
    puts "requesting ##{requested_roles.count} roles in #{Role.count} total roles"
    x.report("v1.x") { 
      n.times { user.has_all_roles? *requested_roles } 
    }
    x.report("v2.0") { 
      n.times { user.has_all_roles_v2? *requested_roles } 
    }
  end
end

n = 1000
user = User.first
user.has_role "admin"
user.has_role "moderator", Forum.first
user.has_role "manager", Group
resources = [ nil, Forum, Forum.first, Forum.last, Group, Group.first, Group.last, nil ]
roles = [ "admin", { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Group } ]

seed_roles(2, resources)
bench_it(user, n, roles)

seed_roles(15, resources)
bench_it(user, n, roles)

seed_roles(80, resources)
bench_it(user, n, roles)

seed_roles(900, resources)
bench_it(user, n, roles)

seed_roles(9000, resources)
bench_it(user, n, roles)