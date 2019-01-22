# RoleMaking 
  Used for role-based resource management, based on the gem cancancan,
  like the ability.rb,you need define resource in resource.rb

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'role_making'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install role_making

## Usage

  ```
  rails generate role_making NAME [ROLE_CNAME] [options]
  ```

  for user ability you can add following in cancancan ability.rb:
  ```ruby
    user ||= User.new

    if user.has_role?(:admin)
      can :manager,:all
    end

    Role.all_without_reserved.each do |role|
      next unless user.has_role?(role.name)
      role.role_resources.each do |role_resource|
        resource = Resource.find_by_name(role_resource.resource_name)
        if resource[:behavior]
          block = resource[:behavior]
          can resource[:verb],resource[:object] do |object|
            block.call(user,object)
          end
        else
          can resource[:verb],resource[:object]
        end
      end

    end

 ```

  Example:
  ```
    rails generate role_making user
    or
    rails generate role_making user Role
  ```

  This will create:

    db/migrate/201506250001_role_making_create_roles.rb
    db/migrate/201506250002_role_making_create_role_resources.rb
    app/models/role.rb
    app/models/role_resource.rb
    add "role_making" to user.rb

  Define resource
  ```ruby
  #with block condition
  group :kefu do
    resource [:read,:update,:destroy], Post do |user,post|
      admin != user
    end

    resource :create,User

  end
 
  
  #with hash condition
  group :kefu do
    resource :edit, Post , type: 3 
  end
  
  #if the condition need eval,you can do like this
  group :kefu do
    resource :edit, Post , con: {user_id: 'user.id'} 
  end


  #with customize resource name

  group :kefu do
    resource :edit, Post , res_name: 'Edit Post'
  end


## Contributing

1. Fork it ( https://github.com/javyliu/role_making/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6.发布 gem
rake build
rake release

