# Replicat
master-slave replication helper for ActiveRecord.

## Installation
```ruby
# Gemfile
gem "replicat"
```

## Usage
Modify your replicable models & config/database.yml.

### model
```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  replicate
end

# config/database.yml
production:
  adapter: mysql2
  encoding: utf8
  host: 192.168.24.1
  port: 3306
  replications:
    slave1:
      adapter: mysql2
      encoding: utf8
      host: 192.168.24.2
      port: 3306
    slave2:
      adapter: mysql2
      encoding: utf8
      host: 192.168.24.3
      port: 3306
    slave3:
      adapter: mysql2
      encoding: utf8
      host: 192.168.24.4
      port: 3306
```

### replication
Now SELECT queries of User model will be sent to slave connections.

```ruby
User.create(name: "replicat")
User.first #=> nil
```

### using
`using` can help you specify particular connection.
`using(:master)` uses master connection.

```ruby
User.create(name: "replicat")
User.using(:master) { User.first } #=> #<User id: 2, name: "replicat">
```

### round-robin
slave connections are balanced by round-robin way.

```ruby
User.using(:slave1) { User.create(name: "replicat") }
User.first #=> #<User id: 2, name: "replicat">
User.first #=> nil
User.first #=> nil
User.first #=> #<User id: 2, name: "replicat">
User.first #=> nil
User.first #=> nil
User.first #=> #<User id: 2, name: "replicat">
User.first #=> nil
User.first #=> nil
```

### multi master-slave set
Pass the master's connection name to `replicate` method.

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  replicate "production_user"
end

# app/models/recipe.rb
class Recipe < ActiveRecord::Base
  replicate "production_recipe"
end

# config/database.yml
production_user:
  <<: *production
  host: 192.168.24.1
  replications:
    slave1:
      <<: *slave
      host: 192.168.24.2
    slave2:
      <<: *slave
      host: 192.168.24.3
    slave3:
      <<: *slave
      host: 192.168.24.4

production_recipe:
  <<: *production
  host: 192.168.24.5
  replications:
    slave1:
      <<: *slave
      host: 192.168.24.6
    slave2:
      <<: *slave
      host: 192.168.24.7
    slave3:
      <<: *slave
      host: 192.168.24.8
```


## For contributors
```sh
# setup gems
bundle install

# setup database
cd spec/dummy
rake db:create
rake db:schema:load RAILS_ENV=test
cd ../../

# run tests
bundle exec rspec
```
