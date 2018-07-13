require "spec_helper"
require "securerandom"

class DummyJob
  def self.perform(uuid)
    sleep 2
    FileUtils.touch(uuid)
  end
end

def LongCleanupJob
  def self.perform(uuid)
    sleep 2

    if Resque.heroku_will_terminate?
      FileUtils.touch(uuid)
    end
  end
end

def get_job_pid(worker)
  pid = nil
  wait condition: -> () {
    pid = worker.instance_variable_get("@child")
    pid.nil?
  }
  pid
end

def wait(timeout: 5000, condition:)
  t0 = Time.now
  while condition.call && ((Time.now - t0) * 1000 < timeout)
    sleep 0.1
  end
end

RSpec.describe 'resque-heroku-signals' do

  context "Signal handling" do
    before do
      @uuid = SecureRandom.uuid
      ENV["TERM_CHILD"] = "1"

      # match production timeouts, this ensures that there are not any edge
      # cases in the underlying resque logic that may conflict with our patches
      ENV["RESQUE_PRE_SHUTDOWN_TIMEOUT"] = "20"
      ENV["RESQUE_TERM_TIMEOUT"] = "8"

      @worker = Resque::Worker.new(:jobs)

      # by default, resque doesn't log anything
      @worker.very_verbose = true
    end

    after do
      FileUtils.remove(@uuid) if File.exist?(@uuid)
    end

    it "ignores the first TERM signal" do
      thread = Thread.new do
        @worker.work(1)
      end

      Resque::Job.create(:jobs, DummyJob, @uuid)
      Process.kill("TERM", get_job_pid(@worker))

      wait condition: ->() { !File.exist?(@uuid) }
      @worker.shutdown
      thread.join

      expect(File.exist?(@uuid)).to eq(true)
    end

    it "ignores the first TERM signal but raises an exception on the second signal" do
      thread = Thread.new { @worker.work(0.1) { puts "hello" } }

      Resque::Job.create(:jobs, DummyJob, @uuid)
      pid = get_job_pid(@worker)

      expect(pid).to_not be_nil

      Process.kill(:TERM, pid)


      # It seems like the second signal isn't received without this
      sleep 0.1
      Process.kill(:TERM, pid)

      @worker.shutdown
      thread.join

      # Implied assertion here is if the file does not exist, then an exception was raised
      expect(File.exist?(@uuid)).to eq(false)
    end

    it 'provides a flag indicating if heroku will soon terminate the worker' do
      expect(Resque.heroku_will_terminate?).to be false

      # `work` must be run in a separate thread, a new process is only created
      # after a job is picked up. The current thread is used to run the job loop
      thread = Thread.new { @worker.work(0.1) { puts "hello" } }

      Resque::Job.create(:jobs, LongCleanupJob, @uuid)
      pid = get_job_pid(@worker)

      expect(pid).to_not be_nil

      Process.kill(:TERM, pid)

      @worker.shutdown
      thread.join

      # if worker will terminate, then the file is written
      expect(File.exist?(@uuid)).to eq(true)
    end
  end
end
