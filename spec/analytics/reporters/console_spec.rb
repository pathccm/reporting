# frozen_string_literal: true

require "spec_helper"

RSpec.describe Path::Reporting::Analytics::Console do
  let(:config) { instance_double(Path::Reporting::Analytics::Configuration) }
  let(:channel) { described_class.new config }

  describe "#record" do
    let(:logger) { double }

    before do
      allow(config).to receive(:logger).and_return(logger)
    end

    context "given the correct required arguments" do
      it "log to the configured logger" do
        expect(logger).to receive(:info).with("[test]:Test_event - \"foo\" (runner) {}")
        channel.record(
          trigger: "test",
          name: "Test_event",
          user: "foo",
          user_type: "runner"
        )
      end
    end

    context "given correct args and metadata" do
      it "log with the given metadata" do
        expect(logger).to receive(:info).with("[test]:Test_event - \"foo\" (runner) {:meta=>\"data\"}")
        channel.record(
          trigger: "test",
          name: "Test_event",
          user: "foo",
          user_type: "runner",
          metadata: { 'meta': "data" }
        )
      end
    end
  end
end
