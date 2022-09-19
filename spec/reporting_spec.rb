# frozen_string_literal: true

RSpec.describe Path::Reporting do
  before { described_class.reset! }

  it "has a version number" do
    expect(Path::Reporting::VERSION).not_to be nil
  end

  describe "#init" do
    specify { expect { described_class.init {} }.to raise_error(StandardError, "Need to set system_name in Reporting config") }
  end

  it "exposes an analyitcs object only after init" do
    expect { described_class.analytics }.to raise_error "Must call init on Path::Reporting library before using"
    described_class.init { |config| config.system_name = "test" }
    expect(described_class.analytics).to be_a Path::Reporting::Analytics
  end
end
