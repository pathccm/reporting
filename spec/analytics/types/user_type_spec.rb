# frozen_string_literal: true

require "spec_helper"

RSpec.describe Path::Reporting::UserType do
  it "exposes constants" do
    expect(Path::Reporting::UserType::PATIENT).not_to be nil
    expect(Path::Reporting::UserType::PROVIDER).not_to be nil
    expect(Path::Reporting::UserType::OPERATOR).not_to be nil
    expect(Path::Reporting::UserType::DEVELOPER).not_to be nil
    expect(Path::Reporting::UserType::SYSTEM).not_to be nil
  end

  describe "#valid?" do
    it "validates a good user type value" do
      expect(Path::Reporting::UserType.valid?("Patient")).to be(true)
    end

    it "denies a bad user type value" do
      expect(Path::Reporting::UserType.valid?("Fake UserType")).to be(false)
    end
  end
end
