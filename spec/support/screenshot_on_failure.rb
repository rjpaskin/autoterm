require "fileutils"

module ScreenshotOnFailure
  SCREENSHOTS_PATH = File.expand_path("../../../tmp/screenshots", __FILE__).freeze

  def screenshot_if_failed(example)
    if failed?(example)
      filename = save_screenshot
      $stderr.puts "Screenshot saved to #{filename}"
    end
  end

  # From capybara-screenshot
  def failed?(example)
    return true if example.exception
    return false unless defined?(::RSpec::Expectations::FailureAggregator)

    failure_notifier = ::RSpec::Support.failure_notifier
    return false unless failure_notifier.is_a?(::RSpec::Expectations::FailureAggregator)

    failure_notifier.failures.any? || failure_notifier.other_errors.any?
  end

  def save_screenshot
    FileUtils.mkdir_p SCREENSHOTS_PATH

    timestamp = Time.now.strftime("%F-%H-%M-%S.%L")

    File.join(SCREENSHOTS_PATH, "screenshot_#{timestamp}.png").tap do |path|
      # no sound, use PNG format
      CommandRunning.run "screencapture", "-x", "-t", "png", path, warn: true
    end
  end
end
