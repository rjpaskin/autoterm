RSpec::Matchers.define :exit_with_code do |expected_code|
  supports_block_expectations

  result = nil

  match do |block|
    begin
      block.call
    rescue SystemExit => error
      result = error.status
    end

    result && result == expected_code
  end

  failure_message do
    "expected block to call exit(#{expected_code}) but exit" +
      (result.nil? ? " not called" : "(#{result}) was called")
  end

  failure_message_when_negated do
    "expected block not to call exit(#{expected_code})"
  end

  description do
    "expect block to call exit(#{exp_code})"
  end
end
