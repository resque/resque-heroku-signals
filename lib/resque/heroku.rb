require 'resque'
require "resque/heroku/version"

module Resque
  module Heroku

  end
end

# https://github.com/resque/resque/issues/1559#issuecomment-310908574
Resque::Worker.class_eval do
  def unregister_signal_handlers
    trap('TERM') do
      trap('TERM') do
        puts "[resque-heroku] received second term signal, throwing term exception"

        trap('TERM') do
          puts "[resque-heroku] third or more time receiving TERM, ignoring"
        end

        raise Resque::TermException.new("SIGTERM")
      end

      puts "[resque-heroku] received first term signal from heroku, ignoring"

    end

    trap('INT', 'DEFAULT')

    begin
      trap('QUIT', 'DEFAULT')
      trap('USR1', 'DEFAULT')
      trap('USR2', 'DEFAULT')
    rescue ArgumentError
    end
  end
end
