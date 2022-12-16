# frozen_string_literal: true

require 'rails_helper'
require 'capybara/cuprite'

Capybara.register_driver :cuprite_chrome do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1400, 1400], url: ENV.fetch('CHROME_URL', 'http://chrome:4444'))
end

Capybara.server_port = 31_337
Capybara.server_host = '0.0.0.0'
Capybara.app_host = "http://#{Socket.gethostname}:#{Capybara.server_port}"
Capybara.javascript_driver = :cuprite_chrome

DatabaseCleaner.allow_production = true
DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
