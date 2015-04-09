$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_record'
require 'settings_on_rails'
require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.order = :random
end

