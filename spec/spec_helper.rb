ENV['RAILS_ENV'] ||= 'test'

##
# Code Climate
#
if ENV['TRAVIS']
  require 'simplecov'
  SimpleCov.start
end

##
# Load Rspec supporting files
#
Dir['./spec/support/**/*.rb'].each { |f| require f }

##
# Detect Rails/Sinatra dummy application based on gemfile name substituted by Appraisal
#
if ENV['APPRAISAL_INITIALIZED'] || ENV['TRAVIS']
  app_name = Pathname.new(ENV['BUNDLE_GEMFILE']).basename.sub('.gemfile', '')
else
  app_name = 'rails_5'
end

app_framework = %w{rails sinatra}.find { |f| app_name.to_s.include?(f) }

##
# Load dummy application and Rspec
#
case app_framework
when 'rails'
  # Load Rails
  require File.expand_path("../app/#{app_name}/config/environment", __FILE__)

  APP_RAKEFILE = File.expand_path("../app/#{app_name}/Rakefile", __FILE__)

  # Load Rspec
  require 'rspec/rails'

  # Configure
  RSpec.configure do |config|
    config.fixture_path = FixtureHelper::FIXTURE_PATH
  end

when 'sinatra'
  # Load Sinatra
  require File.expand_path("../app/#{app_name}/app", __FILE__)

  # Load Rspec
  require 'rspec'

  # Configure
  RSpec.configure do |config|
    config.filter_run_excluding :rails
    config.include FixtureHelper
  end
end

##
# Common Rspec configure
#
RSpec.configure do |config|
  # Turn the deprecation warnings into errors, giving you the full backtrace
  config.raise_errors_for_deprecations!

  config.before(:suite) do
    Config.module_eval do

      # Extend Config module with ability to reset configuration to the default values
      def self.reset
        self.const_name       = 'Settings'
        self.use_env          = false
        self.knockout_prefix  = nil
        self.overwrite_arrays = true
        self.schema           = nil if RUBY_VERSION >= '2.1'
        class_variable_set(:@@_ran_once, false)
      end
    end
  end
end

##
# Print some debug info
#
puts
puts "Gemfile: #{ENV['BUNDLE_GEMFILE']}"
puts 'Version:'

Gem.loaded_specs.each { |name, spec|
  puts "\t#{name}-#{spec.version}" if %w{rails activesupport sqlite3 rspec-rails sinatra}.include?(name)
}

puts
