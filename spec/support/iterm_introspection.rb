require "forwardable"
require "json"
require "open3"
require "ostruct"

module ItermIntrospection
  TIMEOUT_LENGTH = 5 # seconds

  class ItermApp
    extend Forwardable

    def_delegators :@output, :windows, :tabs, :sessions

    def initialize
      reload
    end

    def reload
      result = CommandRunning.osascript(:introspect, raise: true)
      @output = JSON.parse(result.stdout, object_class: OpenStruct)

      self
    end

    def inspect
      "#<iTerm2>"
    end

    private

    attr_reader :output
  end

  def iterm
    @iterm ||= ItermApp.new
  end

  alias_method :iTerm, :iterm
  alias_method :iTerm2, :iterm

  def initial_state
    @initial_state ||= ItermApp.new
  end

  def with_cleanup
    existing_ids = initial_state.windows.map(&:id)

    yield
  ensure
    new_ids = iterm.reload.windows.map(&:id) - existing_ids

    CommandRunning.osascript(:cleanup, *new_ids.map(&:to_s), warn: true)
  end
end
