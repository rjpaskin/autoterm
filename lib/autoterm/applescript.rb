require "delegate"
require "erb"
require "open3"

module Autoterm
  class Applescript
    attr_reader :project

    TEMPLATE_PATH = File.expand_path(
      "../assets/applescript.erb", __FILE__
    ).freeze

    def initialize(project)
      @project = project
    end

    def render
      ERB.new(template, nil, "-").result(RenderContext.for(project))
    end

    def run
      _stdout, stderr, status = Open3.capture3(
        "osascript -",
        stdin_data: render
      )

      raise ExecutionError.new(stderr) unless status.success?
    end

    private

    def template
      File.read(TEMPLATE_PATH)
    end

    class RenderContext < SimpleDelegator
      def self.for(project)
        new(project).instance_eval { binding }
      end

      private

      def escape(string)
        string.to_s.gsub(%{"}, %{\\"})
      end
    end
  end
end
