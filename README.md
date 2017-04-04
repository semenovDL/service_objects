# ServiceObjects

TODO

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'service_objects'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install service_objects

## Usage

```ruby
class User < ActiveRecord::Base
  validates :email, uniqueness: true
end

class User::Create < ServiceObjects::Base
  attr_caller :email

  def process
    user = User.create(email: email)
    errors.push(*user.errors.full_messages) unless user.persisted?
    user
  end
end

process = User::Create.(email: 'alex@gmail.com')
process.result # #<User:0x007fbc70baab10>
process.success? # true
process.call_params # { email: 'alex@gmail.com' }
process.email # alex@gmail.com

invalid_process = User::Create.(email: 'alex@gmail.com')
invalid_process.result # nil
invalid_process.success? # false
invalid_process.error? # true
invalid_process.errors # ["Email can't be blank"]

class User::Update < User::Create
  attr_caller :id, email: nil

  def process
    User.find(id).tap do |user|
        user.update(email: email) if email
    end
  end
end

User::Update.(id: 1) do |user|
  redirect_to user_path(user) and return
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/semenovDL/service_objects.

