# rolify [![build status](https://secure.travis-ci.org/EppO/rolify.png?branch=master)](http://travis-ci.org/EppO/rolify) [![dependency status](https://gemnasium.com/EppO/rolify.png)](https://gemnasium.com/EppO/rolify)

Very simple Roles library without any authorization enforcement supporting scope on resource object.

Let's see an example: 

```ruby
user.has_role?(:moderator, Forum.first) 
=> false # if user is moderator of another Forum
```

This library was intended to be used with [CanCan](https://github.com/ryanb/cancan) and [devise](https://github.com/plataformatec/devise) but should be generic enough to be used by any other authentication/authorization solutions.

## Requirements

* Rails >= 3.1
* ActiveRecord >= 3.1 <b>or</b> Mongoid >= 3.0
* supports ruby 1.9, JRuby 1.6.0+ (in 1.9 mode) and Rubinius 2.0.0dev (in 1.9 mode)
* support of ruby 1.8 has been dropped due to Mongoid 3.0 that only supports 1.9 new hash syntax

## Installation

In <b>Rails 3</b>, add this to your Gemfile and run the +bundle+ command.

```ruby
  gem "rolify"
```

Alternatively, you can install it as a plugin.

```
  rails plugin install git://github.com/EppO/rolify.git
```

## Getting Started

### 1. Generate Role Model

First, create your Role model and migration file using this generator:

```
  rails g rolify:role Role User
```

Role and User classes are the default. You can specify any Role class name you want. This is completly a new file so any name can do the job.
For the User class name, you would probably use the one provided by your authentication solution. rolify just adds some class methods in an existing User class.

If you want to use Mongoid instead of ActiveRecord, follow these [instructions](https://github.com/EppO/rolify/wiki/Configuration), and skip to step #3

### 2. Run the migration (only required when using ActiveRecord)

Let's migrate !

```
  rake db:migrate
```

### 3.1 Configure your user model

This gem adds the `rolify` method to your User class. You can also specify optional callbacks* on the user for when roles are added or removed:

```ruby
  class User < ActiveRecord::Base
    rolify :before_add => :before_add_method

    def :before_add_method(role)
      # do something before it gets added
    end
  end
```

The `rolify` method accepts the following callback* options:

- `before_add`
- `after_add`
- `before_remove`
- `after_remove`

*PLEASE NOTE: callbacks are currently only supported using ActiveRecord ORM. Mongoid will support association callbacks in its 3.1 release (Mongoid current version is 3.0.x)

### 3.2 Configure your resource models

In the resource models you want to apply roles on, just add ``resourcify`` method.
For example, on this ActiveRecord class:

```ruby
class Forum < ActiveRecord::Base
  resourcify
end
```

### 4. Add a role to a user

To define a global role:

```ruby
  user = User.find(1)
  user.add_role :admin
```

To define a role scoped to a resource instance

```ruby
  user = User.find(2)
  user.add_role :moderator, Forum.first
```

To define a role scoped to a resource class

```ruby
  user = User.find(3)
  user.add_role :moderator, Forum
```

That's it !

### 5. Role queries

To check if a user has a global role: 

```ruby
  user = User.find(1)
  user.add_role :admin # sets a global role
  user.has_role? :admin
  => true
```

To check if a user has a role scoped to a resource instance:

```ruby
  user = User.find(2)
  user.add_role :moderator, Forum.first # sets a role scoped to a resource instance
  user.has_role? :moderator, Forum.first
  => true
  user.has_role? :moderator, Forum.last
  => false
```

To check if a user has a role scoped to a resource class:

```ruby
  user = User.find(3)
  user.add_role :moderator, Forum # sets a role scoped to a resource class
  user.has_role? :moderator, Forum
  => true
  user.has_role? :moderator, Forum.first
  => true
  user.has_role? :moderator, Forum.last
  => true
```

A global role overrides resource role request: 

```ruby
  user = User.find(4)
  user.add_role :moderator # sets a global role
  user.has_role? :moderator, Forum.first
  => true
  user.has_role? :moderator, Forum.last
  => true
```

### 6. Resource roles querying 

Starting from rolify 3.0, you can search roles on instance level or class level resources.

#### Instance level

```ruby
  forum = Forum.first
  forum.roles
  # => [ list of roles that are only binded to forum instance ]
  forum.applied_roles
  # => [ list of roles binded to forum instance and to the Forum class ]
```

#### Class level

```ruby
  Forum.with_role(:admin)
  # => [ list of Forum instances that has role "admin" binded to it ] 
  Forum.with_role(:admin, current_user)
  # => [ list of Forum instances that has role "admin" binded to it and belongs to current_user roles ]
  
  Forum.find_roles
  # => [ list of roles that binded to any Forum instance or to the Forum class ]
  Forum.find_roles(:admin)
  # => [ list of roles that binded to any Forum instance or to the Forum class with "admin" as a role name ]
  Forum.find_roles(:admin, current_user)
  # => [ list of roles that binded to any Forum instance or to the Forum class with "admin" as a role name and belongs to current_user roles ]
```

## Resources

* [Wiki](https://github.com/EppO/rolify/wiki)
* [Usage](https://github.com/EppO/rolify/wiki/Usage): all the available commands
* [Tutorial](https://github.com/EppO/rolify/wiki/Tutorial): how to use [rolify](http://eppo.github.com/rolify) with [Devise](https://github.com/plataformatec/devise) and [CanCan](https://github.com/ryanb/cancan).
* [Amazing tutorial](http://railsapps.github.com/tutorial-rails-bootstrap-devise-cancan.html) provided by [RailsApps](http://railsapps.github.com/)

## Questions or Problems?

If you have any issue or feature request with/for rolify, please add an [issue on GitHub](https://github.com/EppO/rolify/issues) or fork the project and send a pull request.