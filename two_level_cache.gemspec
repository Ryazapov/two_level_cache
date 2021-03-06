lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "two_level_cache/version"

Gem::Specification.new do |spec|
  spec.name          = "two_level_cache"
  spec.version       = TwoLevelCache::VERSION
  spec.authors       = ["Eduard Ryazapov"]
  spec.email         = ["eduard.ryazapov@gmail.com"]

  spec.summary       = "TwoLevelCache"
  spec.description   = "TwoLevelCache"
  spec.homepage      = "https://github.com/Ryazapov/two_level_cache"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.add_dependency "activesupport", ">= 5.0.0"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "bundler-audit", "0.6"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.50"
  spec.add_development_dependency "rubocop-rspec", "~> 1.0"
  spec.add_development_dependency "timecop", "~> 0.9"
end
