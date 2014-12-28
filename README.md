# LivedoorBlog

The LivedoorBlog library is used for automating interactions with a livedoor blog.

It can submit entry and upload images.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'livedoor_blog'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install livedoor_blog

## Usage

```ruby
require 'livedoor_blog'

blog = LivedoorBlog.new
blog.login(ENV["livedoor_id"], ENV["password"])
url = blog.upload_image("images/test.jpg")
blog.submit_entry("Test", "Test image: <img src='#{url}'>")
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/livedoor_blog/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

