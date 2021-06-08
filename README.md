# resque-heroku-signals

This gem patches resque to be compatible with the Heroku platform. Specifically it
modifies the UNIX signaling logic to be compatible with the Heroku worker shutdown process.

[Read this GitHub comment for more context & details.](https://github.com/resque/resque/issues/1559)

The version of this gem corresponds to the version of Resque that it is compatible with.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resque-heroku-signals'
```

Since this gem monkeypatches the Heroku worker the `gemspec` is locked to a `x.x.x` version of Resque to ensure the monkeypatched logic is compatible with any changes in the original Resque logic. Issue a PR if this is not compatible with the version of resque you are using.

## Determining When a Process Will Shutdown

Heroku sends a `TERM` signal to a process before hard killing it. If your job communicates with slow external APIs, you may want to make sure you have enough time to receive and handle the response from the external system before executing the API requests.

Ideally, using an idempotency key with each external API request is the best way to ensure that a given API request only runs. However, depending on your application logic this may not be practical and knowing if a process will be terminated in less than 30s by Heroku is a useful tool.

Use `Resque.heroku_will_terminate?` to determine if Heroku will terminate your process within 30s. 

## Example Procfile

```
worker: env QUEUE=* TERM_CHILD=1 INTERVAL=0.1 RESQUE_PRE_SHUTDOWN_TIMEOUT=20 RESQUE_TERM_TIMEOUT=8 bundle exec rake resque:work
```

* `RESQUE_PRE_SHUTDOWN_TIMEOUT` time a job has to finish up before the `TermException` exception is raised
* `RESQUE_TERM_TIMEOUT` time the job has to cleanup & save state
* Total shutdown time should be less than 30s. This is the time [Heroku gives you to cleanup before a `SIGKILL` is issued](https://devcenter.heroku.com/articles/dynos#shutdown)
* `INTERVAL` seconds to wait between jobs

Also, make you don't buffer logs: important log messages could fail to push to stdout during the worker shutdown process:

```ruby
$stdout.sync = true
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
