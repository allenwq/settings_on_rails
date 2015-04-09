require 'settings_on_rails/base'
require 'settings_on_rails/settings_column'
require 'settings_on_rails/settings_handler'
require 'settings_on_rails/exceptions'
require 'settings_on_rails/version'

ActiveRecord::Base.send :include, SettingsOnRails::Base