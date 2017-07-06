require "spec_helper"

RSpec.describe Resque::Heroku do
  it "has a version number" do
    expect(Resque::Heroku::VERSION).not_to be nil
  end

  it "ignores the first TERM signal but raises an exception on the second signal" do

  end
end
