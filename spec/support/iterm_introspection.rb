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

    def current_window
      windows.find(&:current?) or raise "No current window"
    end

    def sessions_in_current_window
      sessions_with(window: current_window.id).tap do |sessions|
        raise "No sessions in current window" if sessions.empty?
      end
    end

    def has_session?(index, filters = {})
      synchronize do
        session = sessions_in_current_window[index]

        raise "No session at index #{index}" unless session

        filters.all? do |name, value|
          case name
          when :contents, :content
            contents = session.contents.strip.split("\n").map(&:strip)

            Array(value).all? {|v| contents.grep(v).any? }
          when :name, :title
            # iTerm (mostly) adds $SHELL in brackets to the name
            session.name.to_s.sub(/ \(.+\)/, "") == value.to_s
          else
            raise "Unknown filter: #{name.inspect}"
          end
        end or raise "Session at index #{index} does not match filters"
      end
    end

    def running?
      synchronize do
        result = CommandRunning.osascript <<-JS, raise: true
          Application("System Events").applicationProcesses.byName("iTerm2").exists()
        JS

        result.stdout.chomp == "true"
      end
    end

    def sessions_with(attributes)
      sessions.select do |session|
        attributes.all? do |key, value|
          session[key] == value
        end
      end
    end

    # Based on Capybara::Node::Base#synchronize
    def synchronize
      start_time = monotonic_time

      begin
        yield
      rescue
        raise if (monotonic_time - start_time) >= TIMEOUT_LENGTH
        sleep(0.05)
        reload
        retry
      end
    end

    def inspect
      "#<iTerm2>"
    end

    private

    attr_reader :output

    # From Capybara::Helpers#monotonic_time
    if defined?(Process::CLOCK_MONOTONIC)
      def monotonic_time
        Process.clock_gettime Process::CLOCK_MONOTONIC
      end
    else
      def monotonic_time
        Time.now.to_f
      end
    end
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
