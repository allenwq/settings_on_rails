require 'settings_on_rails/base'
require 'settings_on_rails/configuration'
require 'settings_on_rails/settings'
require 'settings_on_rails/has_settings'
require 'settings_on_rails/exceptions'
require 'settings_on_rails/version'

ActiveRecord::Base.send :include, SettingsOnRails::Base