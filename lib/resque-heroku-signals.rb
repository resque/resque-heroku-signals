require 'resque'

$HEROKU_WILL_TERMINATE_RESQUE = false

Resque.class_eval do
  def self.heroku_will_terminate?
    !!$HEROKU_WILL_TERMINATE_RESQUE
  end
end

# https://github.com/resque/resque/issues/1559#issuecomment-310908574
Resque::Worker.class_eval do
  def unregister_signal_handlers
    trap('TERM') do
      $HEROKU_WILL_TERMINATE_RESQUE = true

      trap('TERM') do
        log_with_severity :info, "[resque-heroku] received second term signal, throwing term exception"

        trap('TERM') do
          log_with_severity :info, "[resque-heroku] third or more time receiving TERM, ignoring"
        end

        raise Resque::TermException.new("SIGTERM")
      end

      log_with_severity :info, "[resque-heroku] received first term signal from heroku, ignoring"
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
