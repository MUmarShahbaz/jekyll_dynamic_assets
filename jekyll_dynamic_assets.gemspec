# frozen_string_literal: true

require_relative "lib/jekyll_dynamic_assets/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll_dynamic_assets"
  spec.version = JekyllDynamicAssets::VERSION
  spec.authors = ["M. Umar Shahbaz"]
  spec.email = ["m.umarshahbaz.2007@gmail.com"]

  spec.summary = "Dynamically include your asset files"
  spec.description = "Use simple variables to define your master files, presets and manual insertion. Select your assets dynamically via page front matter and config.yml"
  spec.homepage = "https://github.com/MUmarShahbaz/jekyll_dynamic_assets"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/MUmarShahbaz/jekyll_dynamic_assets"
  spec.metadata["changelog_uri"] = "https://github.com/MUmarShahbaz/jekyll_dynamic_assets/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec_file = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == spec_file) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "jekyll", ">= 3.0", "< 5.0"
  spec.add_dependency "liquid", ">= 4.0", "< 6.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
