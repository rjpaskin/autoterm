# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "autoterm/version"

Gem::Specification.new do |spec|
  spec.name          = "autoterm"
  spec.version       = Autoterm::VERSION
  spec.authors       = ["Rob Paskin"]
  spec.email         = ["rjpaskin@gmail.com"]

  spec.summary       = %q{CLI tool to automate creation of iTerm2 sessions}
  spec.homepage      = "https://github.com/rjpaskin/autoterm"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
