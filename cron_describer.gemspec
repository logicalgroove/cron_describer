# frozen_string_literal: true

require_relative "lib/cron_describer/version"

Gem::Specification.new do |spec|
  spec.name = "cron_describer"
  spec.version = CronDescriber::VERSION
  spec.authors = ["Aleksander Lopez Yazikov"]
  spec.email = ["webodessa@gmail.com"]

  spec.summary = "A gem to convert cron schedule strings into human-readable time"
  spec.description = "A Ruby gem that takes a cron schedule string and converts it into a human-readable time description."
  spec.homepage = "https://github.com/logicalgroove/cron_describer"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/logicalgroove/cron_describer"
  spec.metadata["changelog_uri"] = "https://github.com/logicalgroove/cron_describer"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.0"
end
