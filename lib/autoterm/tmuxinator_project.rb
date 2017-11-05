require "yaml"
require "erb"

module Autoterm
  class TmuxinatorProject
    def self.from_yaml_file(project_name)
      filename = "#{ENV["HOME"]}/.tmuxinator/#{project_name}.yml"
      content = File.read(filename)

      # These instance variables could be used in a template,
      # so set to empty objects just in case
      @args = []
      @settings = {}
      parsed_content = ERB.new(content, nil, "-").result(binding)

      new(YAML.load(parsed_content))
    rescue Errno::ENOENT
      raise ProjectNotFoundError.new(project_name, filename)
    rescue SyntaxError, StandardError => error
      raise ParseError.new(project_name, error)
    end

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def root
      config["root"]
    end

    def tabs
      @tabs ||= config["windows"].map do |window|
        name, commands = window.first

        if commands.is_a? Hash
          panes = Array(commands["pre"]) + Array(commands["panes"])

          # Ignore panes for now, flatten commands
          commands = panes.map do |pane|
            pane.is_a?(Hash) ? pane.values.flatten : pane
          end
        end

        Tab.new(name, commands)
      end
    end
  end
end
