# SettingsOnRails[![Build Status](https://travis-ci.org/allenwq/settings_on_rails.svg?branch=master)](https://travis-ci.org/allenwq/settings_on_rails)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'settings_on_rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install settings_on_rails

## Getting Started

Start off by adding a text field to the model which you want it to have settings
```ruby
rails g migration add_settings_column_to_blogs settings_column:text

```

Declare in model
```ruby
class Blog < ActiveRecord::Base
  has_settings_on :settings_column
end
```

Set settings
```ruby
@blog.settings.title = 'My Blog'
@blog.settings(:theme).background_color = 'blue'

@blog.save
```

Get settings
```ruby
@blog.settings(:theme).background_color # returns 'blue'

@blog.settings(:post).pagination # returns nil if not set

```

## Default Values

```ruby
class Blog < ActiveRecord::Base
  has_settings_on :column

  has_settings do |s|
    s.has_key :theme, defaults:{ background_color: 'red', text_size: 50 }
  end
end
```
OR
```ruby
class Blog < ActiveRecord::Base
  has_settings_on :column do |s|
    s.define :theme, defaults:{ background_color: 'red', text_size: 50 }
  end
end
```

## Nested/Multiple Keys


```ruby
@blog.settings(:theme, :homepage).background_color = 'white'
#OR
@blog.settings(:theme).settings(:homepage).background_color = 'white'

@blog.settings(:theme, :homepage).background_color # 'white'
#OR
@blog.settings(:theme).settings(:homepage).background_color # 'white'
```

## Method Name Customization
You can customize the name of the settings method
```ruby
class Blog < ActiveRecord::Base
  has_settings_on :settings_column, method: :preferences
end

# Then you can do
@blog.preferences(:theme).background_color
```

## Contributing

1. Fork it ( https://github.com/allenwq/settings_on_rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
