require "autoterm/version"
require "autoterm/errors"

module Autoterm
  autoload :OSAScript, "autoterm/osascript"
  autoload :CLI, "autoterm/cli"
  autoload :Tab, "autoterm/tab"
  autoload :TmuxinatorProject, "autoterm/tmuxinator_project"
end
