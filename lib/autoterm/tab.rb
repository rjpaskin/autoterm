module Autoterm
  class Tab
    attr_reader :name, :commands

    def initialize(name, commands)
      @name = name.to_s
      @commands = Array(commands).flatten.select do |cmd|
        cmd.to_s.length.nonzero?
      end
    end
  end
end
