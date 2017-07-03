require "spec_helper"

RSpec.describe Resque::Heroku do
  it "has a version number" do
    expect(Resque::Heroku::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
