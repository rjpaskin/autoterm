module Autoterm
  class Error < StandardError; end

  class ProjectNotFoundError < Error
    attr_reader :project_name, :filename

    def initialize(project_name, filename)
      super "Unable to find project '#{project_name}', tried to load #{filename}"

      @project_name = project_name
      @filename = filename
    end
  end

  class ParseError < Error
    def initialize(project_name, original)
      super "Unable to parse project file '#{project_name}':\n  #{original.class}:#{original.message}"

      @project_name = project_name
    end
  end
end
