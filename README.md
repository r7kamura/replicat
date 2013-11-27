# Replicat
Database replication helper for ActiveRecord.

## Installation
```ruby
# Gemfile
gem "replicat"
```

## Usage
1. add replication settings into config/database.yml
2. modify your replicable model

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

### model
We have to set `connection_name` to let the model to know which connection to use.
After this configuration, all SELECT statements are requested to one of the replication connnections.

```ruby
class User < ActiveRecord::Base
  self.connection_name = "production"
end
```
