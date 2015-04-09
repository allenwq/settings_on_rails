require 'support/database_helper'
require 'settings_on_rails'

class Blog < ActiveRecord::Base
  validates_presence_of :settings
end

initialize_database do
  create_table :blogs do |t|
    t.string :name
    t.text :settings
  end
end

