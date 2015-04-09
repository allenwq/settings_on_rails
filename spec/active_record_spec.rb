require 'spec_helper'
require 'settings_on_rails'

class Model < ActiveRecord::Base
end

RSpec.describe ActiveRecord do
  subject { Model }

  it { is_expected.to respond_to(:has_settings_on) }
  it { is_expected.to respond_to(:has_settings) }
end
