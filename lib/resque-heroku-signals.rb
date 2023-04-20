require 'resque'

$HEROKU_WILL_TERMINATE_RESQUE = false

Resque.class_eval do
  def self.heroku_will_terminate?
    !!$HEROKU_WILL_TERMINATE_RESQUE
  end
end

# before bumping resque dependency, check to ensure implementation has not changed
#   https://github.com/resque/resque/blame/v2.0.0/lib/resque/worker.rb#L406
# https://github.com/resque/resque/issues/1559#issuecomment-310908574
Resque::Worker.class_eval do
  # In this patched implementation, the only change is that the worker sends
  # SIGINT to the child, the rest is copied verbatim.
  def new_kill_child
    if @child
      unless child_already_exited?
        if pre_shutdown_timeout && pre_shutdown_timeout > 0.0
          log_with_severity :debug, "Waiting #{pre_shutdown_timeout.to_f}s for child process to exit"
          return if wait_for_child_exit(pre_shutdown_timeout)
        end

        log_with_severity :debug, "Sending INT signal to child #{@child}"
        Process.kill("INT", @child)

        if wait_for_child_exit(term_timeout)
          return
        else
          log_with_severity :debug, "Sending KILL signal to child #{@child}"
          Process.kill("KILL", @child)
        end
      else
        log_with_severity :debug, "Child #{@child} already quit."
      end
    end
  rescue SystemCallError
    log_with_severity :error, "Child #{@child} already quit and reaped."
  end

  def unregister_signal_handlers
    trap("TERM") do
      log_with_severity :debug, "Got TERM signal from Heroku."
      $HEROKU_WILL_TERMINATE_RESQUE = true
    end

    trap("INT") do
      log_with_severity :debug, "Got INT signal from the worker."
      raise Resque::TermException.new("SIGINT")
    end

    begin
      trap('QUIT', 'DEFAULT')
      trap('USR1', 'DEFAULT')
      trap('USR2', 'DEFAULT')
    rescue ArgumentError
    end
  end
end
