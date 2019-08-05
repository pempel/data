# Datagate

For this small and quite simple database-like program I decided to use a CSV file as the main data store. I would implement B-tree indexes to imporve the query performance or I would use a binary file instead of a CSV file as the main data store, but I wanted to focus more on the architecture issues.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'datagate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install datagate

## Usage

Import data from a file into the data store:

    $ cat sample.csv | exe/import

Execute simple queries against the data store:

    $ exe/query -h

    Usage: query [options]
        -s, --select COLUMN_NAME_1,...   For example, "PROJECT,SHOT,VERSION,STATUS"
        -f, --filter EXPRESSION          For example, "PROJECT='the hobbit' AND (SHOT=01 OR SHOT=40)"
        -o, --order COLUMN_NAME_1,...    For example, "FINISH_DATE,INTERNAL_BID"

Select data from the data store:

    $ exe/query -s PROJECT,SHOT,VERSION,STATUS -o FINISH_DATE,INTERNAL_BID

    lotr,3,16,finished
    king kong,42,128,not required
    the hobbit,40,32,finished
    the hobbit,1,64,scheduled

    $ exe/query -s PROJECT,SHOT,VERSION,STATUS -f FINISH_DATE=2006-07-22

    king kong,42,128,not required

Filter data using boolean expressions:

    $ exe/query -s PROJECT,INTERNAL_BID -f 'PROJECT="the hobbit" OR PROJECT="lotr"'

    the hobbit,45.0
    lotr,15.0
    the hobbit,22.8

    $ exe/query -s id,project,shot -f 'PROJECT="the hobbit" AND (SHOT=01 OR SHOT=40)'

    1,the hobbit,01
    4,the hobbit,40

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
