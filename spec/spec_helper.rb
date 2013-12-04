$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "replicat"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../dummy/config/environment", __FILE__)
require "rspec/rails"
require "database_cleaner"

RSpec.configure do |config|
  copy_master_to_slave = proc do |adapter|
    3.times do |i|
      case adapter
      when :mysql2
        system("mysql -u root -e 'drop database dummy_test_slave#{i + 1}' > /dev/null 2> /dev/null")
        system("mysql -u root -e 'create database dummy_test_slave#{i + 1}'")
        system("mysqldump -u root dummy_test | mysql -u root dummy_test_slave#{i + 1}")
      when :sqlite3
        FileUtils.copy("#{Rails.root}/db/test.sqlite3", "#{Rails.root}/db/test_slave#{i + 1}.sqlite3")
      end
    end
  end

  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus

  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion
    copy_master_to_slave.call(:mysql2)
  end

  config.after do
    DatabaseCleaner.clean
    copy_master_to_slave.call(:mysql2)
  end
end
