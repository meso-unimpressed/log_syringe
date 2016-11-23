# LogSyringe

[![Build Status](https://travis-ci.org/meso-unimpressed/log_syringe.svg?branch=master)](https://travis-ci.org/meso-unimpressed/log_syringe)
[![Code Climate](https://codeclimate.com/github/meso-unimpressed/log_syringe/badges/gpa.svg)](https://codeclimate.com/github/meso-unimpressed/log_syringe)
[![Test Coverage](https://codeclimate.com/github/meso-unimpressed/log_syringe/badges/coverage.svg)](https://codeclimate.com/github/meso-unimpressed/log_syringe/coverage)

Add logging to your application without cluttering your code with logger calls.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'log_syringe'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install log_syringe

## Usage

Write your code:

``` ruby
class MyClass
  def some_method(an_argument)
    do_something
  end
end
```

Set up a logger for LogSyringe:

``` ruby
LogSyringe.logger = Logger.new(STDOUT)
```

Inject logging with LogSyringe:

``` ruby
LogSyringe.define(MyClass) do
  log_method(:some_method) do |logger, instance, stats|
    logger.info(
      "some_method was called in #{instance} with params #{stats[:params]}"
    )
  end
end
```

For full documentation see http://www.rubydoc.info/github/meso-unimpressed/log_syringe/master

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/meso-unimpressed/log_syringe.

