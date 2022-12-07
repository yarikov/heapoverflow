RSpec.configure do |config|
  config.before(:suite) do
    Rails.application.load_tasks
    Rake::Task['searchkick:reindex:all'].invoke
    Searchkick.disable_callbacks
  end

  config.around(:each, search: true) do |example|
    Searchkick.callbacks(nil) do
      example.run
    end
  end
end
