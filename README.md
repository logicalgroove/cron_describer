# CronDescriber

CronDescriber is a simple Ruby gem that converts cron schedule strings into human-readable time descriptions. It can help you describe complex cron schedules in a way that is easy to understand.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cron_describer'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install cron_describer
```


##Usage

Here is a basic example of how to use the CronDescriber gem:

```ruby
require 'cron_describer'

cron_schedule = "30 6 1 */3 *"
description = CronDescriber.parse(cron_schedule)
puts description
# Output: "At 6:30 AM, on day 1 of the month, every 3 months"
```

You can pass any valid cron schedule string to the describe_cron method to get a human-readable description.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also `run bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to rubygems.org.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/logicalgroove/cron_describer. This project is intended to be a safe, welcoming space for collaboration,

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
