# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Time::DATE_FORMATS[:my_short] = '%b %d at %k:%M'
