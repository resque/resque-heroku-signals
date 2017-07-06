# resque-heroku

This gem patches resque to be compatible with the Heroku platform. Specifically it
modifies the UNIX signaling logic to be compatible with the Heroku worker shutdown process.

[Read this GitHub comment for more context & details.](https://github.com/resque/resque/issues/1559)

The version of this gem corresponds to the version of Resque that it is compatible with.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resque-heroku'
```

## Example Procfile

```
worker: env QUEUE=* TERM_CHILD=1 INTERVAL=0.1 RESQUE_PRE_SHUTDOWN_TIMEOUT=20 RESQUE_TERM_TIMEOUT=8 bundle exec rake resque:work

```

* Total time should be less than 0
* `RESQUE_PRE_SHUTDOWN_TIMEOUT` time a job has to finish up before the `TermException` exception is raised
* `RESQUE_TERM_TIMEOUT` time the job has to cleanup & save state
* `INTERVAL` seconds to wait between jobs

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
