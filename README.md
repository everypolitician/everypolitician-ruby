# Everypolitician [![Build Status](https://travis-ci.org/everypolitician/everypolitician-ruby.svg?branch=v0.1.0)](https://travis-ci.org/everypolitician/everypolitician-ruby) [![Gem Version](https://badge.fury.io/rb/everypolitician.svg)](https://badge.fury.io/rb/everypolitician)

Interface with EveryPolitician data from your Ruby application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'everypolitician'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install everypolitician

## Usage

Use as shown below, passing the `:slug` of the country to the `country` method, and the `:slug` of the legislature to the `legislature` method. Examples:

```ruby
require 'everypolitician'

australia = Everypolitician::Index.new.country('Australia')
australia.code # => "AU"
senate = australia.legislature('Senate')
senate.popolo # => #<Everypolitician::Popolo::JSON>

united_kingdom = Everypolitician::Index.new.country('UK')
house_of_commons = united_kingdom.legislature('Commons')

american_samoa = Everypolitician::Index.new.country('American-Samoa')
house_of_representatives = american_samoa.legislature('House')

united_arab_emirates = Everypolitician::Index.new.country('United-Arab-Emirates')
national_council = united_arab_emirates.legislature('Federal-National-Council')

algeria = Everypolitician::Index.new.country('Algeria')
national_assembly = algeria.legislature('Majlis')

# Iterate though all known countries
Everypolitician::Index.new.countries do |country|
  puts "#{country.name} has #{country.legislatures.size} legislature(s)"
end
```

If you want to point at a different version of `countries.json` you can supply an
`index_url` option to `Everypolitician::Index.new`.

```ruby
Everypolitician::Index.new(index_url: 'https://cdn.rawgit.com/everypolitician/everypolitician-data/080cb46/countries.json')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/everypolitician.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
