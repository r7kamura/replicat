$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "replicat"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../dummy/config/environment", __FILE__)
require "rspec/rails"
require "database_cleaner"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus

  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion
    3.times do |i|
      FileUtils.copy("#{Rails.root}/db/test.sqlite3", "#{Rails.root}/db/test_slave#{i + 1}.sqlite3")
    end
  end

  config.after do
    DatabaseCleaner.clean
    3.times do |i|
      FileUtils.copy("#{Rails.root}/db/test.sqlite3", "#{Rails.root}/db/test_slave#{i + 1}.sqlite3")
    end
  end
end
