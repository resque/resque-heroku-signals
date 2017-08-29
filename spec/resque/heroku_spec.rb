require "spec_helper"
require "securerandom"

class DummyJob
  def self.perform(uuid)
    sleep 2
    FileUtils.touch(uuid)
  end
end

RSpec.describe 'resque-heroku-signals' do

  context "Signal handling" do
    before do
      @uuid = SecureRandom.uuid
      ENV["TERM_CHILD"] = "1"

      @worker = Resque::Worker.new(:jobs)
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
      thread = Thread.new do
        @worker.work(1)
      end
      Resque::Job.create(:jobs, DummyJob, @uuid)
      pid = get_job_pid(@worker)
      Process.kill("TERM", pid)
      sleep 0 # It seems like the second signal isn't received without this
      Process.kill("TERM", pid)

      @worker.shutdown
      thread.join

      expect(File.exist?(@uuid)).to eq(false)
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
