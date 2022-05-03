# frozen_string_literal: true

require_relative "lib/path/reporting/version"

Gem::Specification.new do |spec|
  spec.name = "path-reporting"
  spec.version = Path::Reporting::VERSION
  spec.authors = ["Alexis Hushbeck"]
  spec.email = ["alexis.hushbeck@pathccm.com"]

  spec.summary = "Reporting gem for Path Mental Health"
  spec.homepage = "https://github.com/pathccm/reporting"
  spec.required_ruby_version = ">= 3.0.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pathccm/reporting"
  spec.metadata["changelog_uri"] = "https://github.com/pathccm/reporting/commits"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "amplitude-api"
  spec.add_development_dependency "yard"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
