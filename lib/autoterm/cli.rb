module Autoterm
  class CLI
    def self.run(args)
      new(args).run
    end

    def initialize(args)
      @args = args
    end

    def run
      if project_name.to_s.length.zero?
        error! "Provide a project name"
      end

      Applescript.new(
        TmuxinatorProject.from_yaml_file(project_name)
      ).run
    rescue Error => error
      error! error
    end

    private

    attr_reader :args

    def project_name
      @project_name ||= args[0]
    end

    def error!(message)
      $stderr.puts message
      Kernel.exit 1
    end
  end
end
