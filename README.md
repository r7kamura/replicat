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
# INSERT query is sent to master.
User.create(name: "replicat")

# SELECT query is sent to slave.
User.first
```

### using
`using` can help you specify particular connection.
When you want to send queries to master,
you can use `using(:master)` to do that (:master is reserved name for `using` method).
When you want to send queries to a particular slave,
you can use the slave's name on database.yml like `using(:slave1)`.

```ruby
# SELECT query is sent to master.
User.using(:master) { User.first }

# INSERT query is sent to slave1.
User.using(:slave1) { User.create(name: "replicat") }
```

### round-robin
slave connections are balanced by round-robin way.

```ruby
User.first # sent to slave1
User.first # sent to slave2
User.first # sent to slave3
User.first # sent to slave1
User.first # sent to slave2
User.first # sent to slave3
User.first # sent to slave1
User.first # sent to slave2
User.first # sent to slave3
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
