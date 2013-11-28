# Replicat
Database replication helper for ActiveRecord.

## Installation
```ruby
# Gemfile
gem "replicat"
```

## Usage
Modify your replicable models & config/database.yml.

### model
```ruby
class User < ActiveRecord::Base
  replicate
end
```

### config/database.yml
```
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
