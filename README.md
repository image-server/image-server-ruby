# ImageServer Ruby Client

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/image/server/ruby`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'image-server'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install image-server

## Usage

Call this method to modify defaults in your initializers.
```ruby
ImageServer.configure do |config|
  config.logger = Rails.logger
  config.upload_host = '127.0.0.1'
  config.cdn_protocol = '//:'
  config.cdn_host = 'example.com'
  config.sharded_cdn_host = 'img-%d.example.com'
  config.sharded_host_count = 3
end
```

To prepare a model to use image server
```ruby
class AddImageHashToProducts < ActiveRecord::Migration
  def change
    add_column :products, :image_hash, :string, :limit => 32
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/image-server/image-server-ruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

