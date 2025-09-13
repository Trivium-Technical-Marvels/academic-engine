require_relative 'lib/academic/engine/version'

Gem::Specification.new do |spec|
  spec.name        = 'academic-engine'
  spec.version     = Academic::Engine::VERSION
  spec.authors     = ['BITS SIMS Development Team']
  spec.email       = ['dev.team@bitscollege.edu.et']
  spec.homepage    = 'https://bitscollege.edu.et'
  spec.summary     = 'Academic Engine for SIMS'
  spec.description = 'Academic Engine for SIMS'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.3.8'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/bitscollege/academic-engine'
  spec.metadata['changelog_uri'] = 'https://github.com/bitscollege/academic-engine/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md']
  end

  # -- Dependencies --
  spec.add_dependency 'rails', '>= 8.0.2.1'
  spec.add_dependency 'sims-common'

  # -- Development Dependencies --
  spec.add_development_dependency 'bullet'
  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'database_cleaner-active_record'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'lograge' # keep here if you only use in dev
  spec.add_development_dependency 'pry-rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rswag-api'
  spec.add_development_dependency 'rswag-ui'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'ruby-lsp'
  spec.add_development_dependency 'ruby-lsp-rails'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'yard'
end
