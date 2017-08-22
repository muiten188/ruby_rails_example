require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RegulationCheck
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # log出力
    config.logger = Logger.new(config.paths['log'].first, 'daily')
    config.logger.formatter = Logger::Formatter.new
    config.logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    config.log_level = :debug
    config.assets.paths << Rails.root.join('vendor', 'assets', 'images', 'fonts')
    config.assets.enabled = true
  end
end
