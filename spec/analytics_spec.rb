# frozen_string_literal: true

require "spec_helper"

RSpec.describe Path::Reporting::Analytics do
  let(:config) { instance_double(Path::Reporting::Configuration, analytics: analytics_config) }
  let(:analytics_config) { instance_double(Path::Reporting::Analytics::Configuration) }
  let(:recorder) { described_class.new config }

  describe "#clients" do
    subject { recorder.clients }

    context "when no clients are configured" do
      before do
        allow(analytics_config).to receive("amplitude_enabled?").and_return(false)
        allow(analytics_config).to receive("console_enabled?").and_return(false)
        recorder.instance_variable_set "@clients", nil
      end

      it { is_expected.to eq({ 'amplitude': nil, 'console': nil }) }
    end

    context "when amplitude is turned on" do
      let(:amplitude_channel) { instance_double(Path::Reporting::Analytics::Amplitude) }

      before do
        allow(analytics_config).to receive("amplitude_enabled?").and_return(true)
        allow(analytics_config).to receive("console_enabled?").and_return(false)
        allow(Path::Reporting::Analytics::Amplitude).to receive("new").and_return(amplitude_channel)
        recorder.instance_variable_set "@clients", nil
      end

      it { is_expected.to eq({ 'amplitude': amplitude_channel, 'console': nil }) }
    end

    context "when console is turned on" do
      let(:console_channel) { instance_double(Path::Reporting::Analytics::Console) }

      before do
        allow(analytics_config).to receive("amplitude_enabled?").and_return(false)
        allow(analytics_config).to receive("console_enabled?").and_return(true)
        allow(Path::Reporting::Analytics::Console).to receive("new").and_return(console_channel)
        recorder.instance_variable_set "@clients", nil
      end

      it { is_expected.to eq({ 'amplitude': nil, 'console': console_channel }) }
    end

    context "when amplitude and console are turned on" do
      let(:amplitude_channel) { instance_double(Path::Reporting::Analytics::Amplitude) }
      let(:console_channel) { instance_double(Path::Reporting::Analytics::Console) }

      before do
        allow(analytics_config).to receive("amplitude_enabled?").and_return(true)
        allow(analytics_config).to receive("console_enabled?").and_return(true)
        allow(Path::Reporting::Analytics::Amplitude).to receive("new").and_return(amplitude_channel)
        allow(Path::Reporting::Analytics::Console).to receive("new").and_return(console_channel)
        recorder.instance_variable_set "@clients", nil
      end

      it { is_expected.to eq({ 'amplitude': amplitude_channel, 'console': console_channel }) }
    end
  end

  describe "#format_event_name" do
    it "formats event name data properly" do
      expect(recorder.format_event_name(
               product_code: "wrong case",
               product_area: "not Even tryinG",
               name: "ALL THE WRONG CASE"
             )).to eq("WRONG_CASE_NotEvenTrying_All_the_wrong_case")
    end
  end

  describe "#record" do
    let(:console_channel) { instance_double(Path::Reporting::Analytics::Console) }

    before { recorder.instance_variable_set "@clients", { 'amplitude': nil, 'console': console_channel } }
    before { allow(Path::Reporting::Trigger).to receive(:valid?).and_return(true) }
    before { allow(Path::Reporting::UserType).to receive(:valid?).and_return(true) }

    context "given valid parameters" do
      it "passes along all values them" do
        expect(console_channel).to receive(:record).with(
          trigger: "auto",
          name: "RSPEC_RecorderTest_Test_run",
          user: { 'id': 1 },
          user_type: "rspec",
          metadata: {}
        )
        recorder.record(
          product_code: "rspec",
          product_area: "recorder test",
          name: "test run",
          user: { 'id': 1 },
          user_type: "rspec",
          trigger: "auto"
        )
      end

      let(:error_to_raise) { StandardError.new "test" }

      it "passes along all values them" do
        expect(console_channel).to receive(:record).and_raise(error_to_raise)
        results = recorder.record(
          product_code: "rspec",
          product_area: "recorder test",
          name: "test run",
          user: { 'id': 1 },
          user_type: "rspec",
          trigger: "auto"
        )
        expect(results).to contain_exactly(
          { reporter: "amplitude", result: nil },
          { reporter: "console", result: error_to_raise }
        )
      end
    end

    context "given neither a user device id nor user id" do
      specify do
        expect do
          recorder.record(product_code: "rspec", product_area: "recorder test", name: "test run", user: {})
        end.to raise_error Path::Reporting::Error, "No user hash provided when reporting analytics"
      end
    end

    context "given just a user device id" do
      it "passes along all values them" do
        expect(console_channel).to receive(:record).with(
          trigger: "auto",
          name: "RSPEC_RecorderTest_Test_run",
          user: { 'device_id': 1 },
          user_type: "rspec",
          metadata: {}
        )
        recorder.record(
          product_code: "rspec",
          product_area: "recorder test",
          name: "test run",
          user: { 'device_id': 1 },
          user_type: "rspec",
          trigger: "auto"
        )
      end
    end
  end
end
