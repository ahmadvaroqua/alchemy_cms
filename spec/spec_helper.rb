require 'simplecov'
require 'coveralls'

if ENV['CI']
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
else
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end
SimpleCov.start 'alchemy'

begin
  require 'spork'
rescue LoadError => e
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)

require "rails/test_help"
require "rspec/rails"
require 'factory_girl'
require 'factories.rb'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!
# Disable rails loggin for faster IO. Remove this if you want to have a test.log
Rails.logger.level = 4

# Configure capybara for integration testing
require "capybara/rails"
require 'capybara/poltergeist'
Capybara.default_driver = :rack_test
Capybara.default_selector = :css
Capybara.register_driver(:rack_test_translated_header) do |app|
  Capybara::RackTest::Driver.new(app, :headers => { 'HTTP_ACCEPT_LANGUAGE' => 'de' })
end
Capybara.javascript_driver = :poltergeist

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Alchemy::Engine.routes.url_helpers
  config.include Devise::TestHelpers, :type => :controller
  config.use_transactional_fixtures = true
  # Make sure the database is clean and ready for test
  config.before(:suite) do
    truncate_all_tables
    Alchemy::Seeder.seed!
  end
  # Ensuring that the locale is always resetted to :en before running any tests
  config.before(:each) do
    Alchemy::Site.current = nil
    ::I18n.locale = :en
  end
end
