require "spec_helper"

RSpec.describe Backup::Influxdb do
  it "has a version number" do
    expect(Backup::Influxdb::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
