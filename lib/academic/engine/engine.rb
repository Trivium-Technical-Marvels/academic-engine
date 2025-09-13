module Academic
  module Engine
    # rubocop:disable all
    class Engine < ::Rails::Engine
      isolate_namespace Academic::Engine

      config.generators.api_only = true

      # Ensure generators use RSpec and FactoryBot instead of Minitest/fixtures
      config.generators do |g|
        g.test_framework :rspec,
                         fixtures: true,
                         view_specs: false,
                         helper_specs: false,
                         routing_specs: false,
                         controller_specs: false,
                         request_specs: true
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
      end
    end
  end
end
