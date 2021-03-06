# Settings on Rails
[![Build Status](https://travis-ci.org/allenwq/settings_on_rails.svg?branch=master)](https://travis-ci.org/allenwq/settings_on_rails)
[![Coverage Status](https://coveralls.io/repos/allenwq/settings_on_rails/badge.svg?branch=master)](https://coveralls.io/r/allenwq/settings_on_rails?branch=master)

## Installation

If you are using [Bundler](http://bundler.io/), add this line to your application's Gemfile:

```ruby
gem 'settings_on_rails'
```

And then execute:

    $ bundle

Alternatively, install it by running:

    $ gem install settings_on_rails

## Getting Started

### Add database column

Start by adding a text field to the model on which you want settings:

```ruby
rails g migration add_settings_column_to_blogs settings_column:text
```

### Declare in model

```ruby
class Blog < ActiveRecord::Base
  has_settings_on :settings_column
end
```

### Set settings

```ruby
@blog.settings.title = 'My Space'
@blog.settings(:theme).background_color = 'blue'

@blog.save
```

### Get settings

```ruby
@blog.settings(:theme).background_color
=> 'blue'

# returns nil if not set
@blog.settings(:post).pagination
=> nil
```

## Defining Default Values

```ruby
class Blog < ActiveRecord::Base
  has_settings_on :column

  has_settings do |s|
    s.key :theme, defaults:{ background_color: 'red', text_size: 50 }
    s.attr :title, default: 'My Space'
  end
end
```

OR

```ruby
class Blog < ActiveRecord::Base
  has_settings_on :column do |s|
    s.key :theme, defaults: { background_color: 'red', text_size: 50 }
    s.attr :title, default: 'My Space'
  end
end
```

You can get these defaults by:

```ruby
@blog.settings(:theme).background_color
=> 'red'

@blog.settings(:theme).text_size
=> 50

@blog.settings.title
=> 'My Space'
```

## Nested Keys

Settings on Rails supports nested keys by chaining calls to the `settings` method:

```ruby
# Set
@blog.settings(:theme).settings(:homepage).background_color = 'white'

# Get
@blog.settings(:theme).settings(:homepage).background_color
=> 'white'
```

## Multiple Keys

You can also define multiple keys in the following way, this is equivalent to nested keys:

```ruby
# Set
@blog.settings(:theme, :homepage).background_color = 'white'

# Get
@blog.settings(:theme, :homepage).background_color
=> 'white'
```


## Method Name Customization

You can customize the name of the `settings` method:

```ruby
class Blog < ActiveRecord::Base
  has_settings_on :settings_column, method: :preferences
end
```

Which allows you to do:

```ruby
@blog.preferences(:theme).background_color
```

## Contributing

1. Fork it ( https://github.com/allenwq/settings_on_rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
