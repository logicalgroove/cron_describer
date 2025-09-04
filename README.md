# CronDescriber

CronDescriber is a Ruby gem that converts cron schedule strings into human-readable time descriptions. It supports the full cron syntax including ranges, lists, step values, and provides comprehensive input validation with meaningful error messages.

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

## Usage

### Basic Examples

```ruby
require 'cron_describer'

# Simple time
CronDescriber.parse("30 6 * * *")
# => "At 6:30 AM"

# Every day at midnight
CronDescriber.parse("0 0 * * *")
# => "At 12:00 AM"

# Afternoon time
CronDescriber.parse("15 14 * * *")
# => "At 2:15 PM"
```

### Advanced Cron Patterns

#### Step Values
```ruby
# Every 5 minutes
CronDescriber.parse("*/5 * * * *")
# => "Every 5 minutes"

# Every 2 hours
CronDescriber.parse("0 */2 * * *")
# => "Every 2 hours"

# Every 3 months on the 1st
CronDescriber.parse("0 0 1 */3 *")
# => "At 12:00 AM, on day 1 of the month, every 3 months"
```

#### Ranges
```ruby
# Weekdays (Monday through Friday)
CronDescriber.parse("0 9 * * 1-5")
# => "At 9:00 AM, only on Monday through Friday"

# Summer months
CronDescriber.parse("0 12 1 6-8 *")
# => "At 12:00 PM, on day 1 of the month, June through August"
```

#### Lists
```ruby
# Specific days of the week
CronDescriber.parse("0 9 * * 1,3,5")
# => "At 9:00 AM, only on Monday, Wednesday, Friday"

# Quarter hours
CronDescriber.parse("0,15,30,45 * * * *")
# => "At 0, 15, 30, 45 minutes past the hour"

# Multiple specific hours
CronDescriber.parse("0 9,13,17 * * *")
# => "At 9:00 AM, 1:00 PM, 5:00 PM"
```

#### Wildcard Patterns
```ruby
# Every minute
CronDescriber.parse("* * * * *")
# => "Every minute"

# Every minute during 9 AM
CronDescriber.parse("* 9 * * *")
# => "Every minute during 9:00 AM"
```

## Supported Cron Features

- ✅ **Standard 5-field format**: `minute hour day_of_month month day_of_week`
- ✅ **Wildcards**: `*` for any value
- ✅ **Step values**: `*/5` (every 5), `10-50/5` (every 5 from 10 to 50)
- ✅ **Ranges**: `1-5` (1 through 5), `MON-FRI`
- ✅ **Lists**: `1,3,5` (values 1, 3, and 5)
- ✅ **Day of week**: Both `0` and `7` supported for Sunday
- ✅ **12-hour time format**: Proper AM/PM conversion
- ✅ **Input validation**: Comprehensive field validation with helpful error messages
- ✅ **Error handling**: Graceful handling of malformed cron expressions

## Field Ranges

- **Minute**: 0-59
- **Hour**: 0-23 (converted to 12-hour AM/PM format in output)
- **Day of Month**: 1-31
- **Month**: 1-12
- **Day of Week**: 0-7 (0 and 7 both represent Sunday)

## Error Handling

The gem provides detailed error messages for invalid input:

```ruby
# Invalid minute value
CronDescriber.parse("60 12 * * *")
# => CronDescriber::Error: Invalid minute field: 60

# Wrong number of fields
CronDescriber.parse("30 6 1")
# => CronDescriber::Error: Invalid cron format. Expected 5 fields (minute hour day_of_month month day_of_week)

# Empty input
CronDescriber.parse("")
# => CronDescriber::Error: Cron schedule cannot be nil or empty
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also `run bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to rubygems.org.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/logicalgroove/cron_describer. This project is intended to be a safe, welcoming space for collaboration,

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
