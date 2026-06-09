# frozen_string_literal: true

require 'rails_helper'
require 'capybara/email/rspec'
require 'capybara/cuprite'

Capybara.register_driver :cuprite_chrome do |app|
  options = {
    window_size: [1400, 1400],
    browser_options: { 'no-sandbox' => nil }
  }
  options[:process_timeout] = 60 if ENV['CI']
  Capybara::Cuprite::Driver.new(app, options)
end

Capybara.server_port = 31_337
Capybara.server_host = '0.0.0.0'
Capybara.app_host = "http://#{Socket.gethostname}:#{Capybara.server_port}"

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :system
  config.include ApplicationHelper, type: :system

  config.around(:each, type: :system) do |example|
    was_host = Rails.application.default_url_options[:host]
    Rails.application.default_url_options[:host] = Capybara.app_host
    example.run
    Rails.application.default_url_options[:host] = was_host
  end

  config.prepend_before(:each, type: :system) do
    driven_by :cuprite_chrome
  end
end
