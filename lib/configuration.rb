# frozen_string_literal: true

require_relative "analytics/configuration"

module Path
  module Reporting
    # @!attribute [r] analytics
    #   @return [Analytics::Configuration] the configuration for analytics reporting
    class Configuration
      attr_reader :analytics

      # Create a new configuration. Sub configuration's will be used by the
      # various reporting sections.
      # @see Analytics::Configuration
      def initialize
        @analytics = Analytics::Configuration.new
      end
    end
  end
end
