require "bundler/setup"
require "autoterm"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  Dir[File.expand_path("../../spec/support/**/*.rb", __FILE__)].sort.each {|f| require f }

  config.include CommandRunning, type: :integration
  config.include ScreenshotOnFailure, type: :integration
  config.include ItermIntrospection, type: :integration

  config.after(:example, type: :integration) do |example|
    screenshot_if_failed(example)
  end

  config.around(:example, type: :integration) do |example|
    with_cleanup { example.run }
  end
end
