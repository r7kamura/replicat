$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "replicat"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../dummy/config/environment", __FILE__)
require "rspec/rails"

3.times {|i| FileUtils.copy("#{Rails.root}/db/test.sqlite3", "#{Rails.root}/db/test_slave#{i + 1}.sqlite3") }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.use_transactional_fixtures = true
  config.filter_run :focus
end
