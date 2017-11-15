if ENV["CI"]
  require "simplecov"
  require "coveralls"

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    %w[spec].each do |ignore_path|
      add_filter(ignore_path)
    end
  end
end

require "bundler/setup"
require "rack/test"
require "webmock/rspec"
require "rspec/its"

require "omniauth/chatwork"

OmniAuth.config.logger = Logger.new("/dev/null")

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

def spec_dir
  Pathname(__dir__)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Rack::Test::Methods
  config.include FixtureUtil
  config.include OmniAuth::Test::StrategyTestCase, type: :strategy

  config.extend OmniAuth::Test::StrategyMacros, type: :strategy
end
