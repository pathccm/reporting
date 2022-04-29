# frozen_string_literal: true

require "spec_helper"

RSpec.describe Path::Reporting::Trigger do
  it "exposes constants" do
    expect(Path::Reporting::Trigger::INTERACTION).not_to be nil
    expect(Path::Reporting::Trigger::PAGE_VIEW).not_to be nil
    expect(Path::Reporting::Trigger::AUTOMATION).not_to be nil
  end

  describe "#valid?" do
    it "validates a good trigger value" do
      expect(Path::Reporting::Trigger.valid?("Interaction")).to be(true)
    end

    it "denies a bad trigger value" do
      expect(Path::Reporting::Trigger.valid?("Fake Trigger")).to be(false)
    end
  end
end
