# frozen_string_literal: true

require 'simplecov'

SimpleCov.start('rails') do
  enable_coverage :branch
end
SimpleCov.minimum_coverage line: 92, branch: 68
