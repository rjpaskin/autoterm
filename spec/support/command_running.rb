module CommandRunning
  Result = Struct.new(:stdout, :stderr, :status)

  def self.run(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}

    env = {
      "HOME" => File.expand_path("../../fixtures", __FILE__)
    }.merge(options.fetch(:env, {}))

    result = Result.new *Open3.capture3(env, *args)

    if result.status.success?

    else
      warn result.stdout if options[:warn]
      raise "#{result.status}\n#{result.stderr}" if options[:raise]
    end

    result
  end

  def self.osascript(filename, *extra_args)
    args = if filename.is_a? Symbol
      [File.expand_path("../../assets/#{filename}.js", __FILE__)]
    else
      ["-e", filename.gsub("\s+", "")]
    end

    run "osascript", "-l", "JavaScript", *args, *extra_args
  end

  def run(*args)
    CommandRunning.run(*args)
  end

  def osascript(*args)
    CommandRunning.osascript(*args)
  end
end
