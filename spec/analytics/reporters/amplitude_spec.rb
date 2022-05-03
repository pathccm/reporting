# frozen_string_literal: true

require "spec_helper"

RSpec.describe Path::Reporting::Analytics::Amplitude do
  let(:config) { instance_double(Path::Reporting::Configuration, analytics: analytics_config, system_name: 'test') }
  let(:analytics_config) { instance_double(Path::Reporting::Analytics::Configuration) }
  let(:channel) { described_class }

  describe "#initialize" do
    let(:input_config) { { 'api_key': "test", 'abc': "easy as 123" } }
    let(:api_config) { instance_double(AmplitudeAPI::Config) }

    it "initializes Amplitude and passes along the configuration" do
      expect(analytics_config).to receive(:amplitude_config).and_return(input_config)
      expect(AmplitudeAPI).to receive("config").twice.and_return(api_config)
      expect(api_config).to receive("instance_variable_set").with("@api_key", "test")
      expect(api_config).to receive("instance_variable_set").with("@abc", "easy as 123")
      channel.new config
    end
  end

  describe "#scrub_pii" do
    let(:analytics_config) { instance_double(Path::Reporting::Analytics::Configuration, "amplitude_config" => {}) }
    let(:channel_instance) { described_class.new config }

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
    let(:analytics_config) { instance_double(Path::Reporting::Analytics::Configuration, "amplitude_config" => {}) }
    let(:channel_instance) { described_class.new config }
    let(:api_event) { instance_double(AmplitudeAPI::Event) }
    let(:response) { instance_double(Faraday::Response, success?: true) }

    it "report event to Amplitude using the API" do
      expect(AmplitudeAPI::Event).to receive(:new).with({
                                                          'event_properties': { 'system_name': 'test', 'trigger': "test" },
                                                          'event_type': "Test_event",
                                                          'user_id': "1",
                                                          'user_properties': { 'id': 1, 'user_type': "runner" }
                                                        }).and_return(api_event)
      expect(AmplitudeAPI).to receive(:track).with(api_event).and_return(response)
      channel_instance.record(
        trigger: "test",
        name: "Test_event",
        user: { 'id': 1 },
        user_type: "runner"
      )
    end
  end
end
