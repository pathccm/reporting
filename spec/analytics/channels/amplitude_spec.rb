# frozen_string_literal: true

require "spec_helper"

RSpec.describe Path::Reporting::Analytics::Channels::Amplitude do
  let(:analytics_config) { instance_double(Path::Reporting::Analytics::Configuration) }
  let(:channel) { described_class }
  let(:simple_config_input) { instance_double(Path::Reporting::Analytics::Configuration, "amplitude_config" => {}) }

  describe "@channel_name" do
    let(:channel_instance) { described_class.new simple_config_input }
    specify { expect(channel_instance.channel_name).to eq("Amplitude") }
  end

  describe "#initialize" do
    let(:input_config) { { 'api_key': "test", 'abc': "easy as 123" } }
    let(:api_config) { instance_double(AmplitudeAPI::Config) }

    it "initializes Amplitude and passes along the configuration" do
      expect(analytics_config).to receive(:amplitude_config).and_return(input_config)
      expect(AmplitudeAPI).to receive("config").twice.and_return(api_config)
      expect(api_config).to receive("instance_variable_set").with("@api_key", "test")
      expect(api_config).to receive("instance_variable_set").with("@abc", "easy as 123")
      channel.new analytics_config
    end
  end

  describe "#scrub_pii" do
    let(:channel_instance) { described_class.new simple_config_input }

    it "strips PII from simple metadata" do
      results = channel_instance.scrub_pii({ 'fine': "stays", 'ssn': "goes" })
      expect(results).to eq({ 'fine': "stays", 'ssn': "XXXXXXXX" })
    end

    it "strips PII from nested metadata" do
      results = channel_instance.scrub_pii([1, { 'fine': "stays", 'ssn': "goes" }])
      expect(results).to eq([1, { 'fine': "stays", 'ssn': "XXXXXXXX" }])
    end

    it "does not scrub inifinitely deep" do
      results = channel_instance.scrub_pii({ "1": { "2": { "3": { "4": { "5": { "this": "is removed" } } } } } })
      expect(results).to eq({ "1": { "2": { "3": { "4": { "5": "[DATA]" } } } } })
    end
  end

  describe "#record" do
    let(:channel_instance) { described_class.new simple_config_input }
    let(:api_event) { instance_double(AmplitudeAPI::Event) }

    it "report event to Amplitude using the API" do
      expect(AmplitudeAPI::Event).to receive(:new).with({
                                                          'event_properties': { 'trigger': "test" },
                                                          'event_type': "Test_event",
                                                          'user_id': "1",
                                                          'user_properties': { 'id': 1, 'user_type': "runner" }
                                                        }).and_return(api_event)
      expect(AmplitudeAPI).to receive(:track).with(api_event)
      channel_instance.record(
        trigger: "test",
        name: "Test_event",
        user: { 'id': 1 },
        user_type: "runner"
      )
    end
  end
end
