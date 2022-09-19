# frozen_string_literal: true

require_relative "analytics/configuration"

module Path
  module Reporting
    # Global configuration for all reporting sub-modules
    # @!attribute [r] analytics
    #   @return [Analytics::Configuration] the configuration for analytics reporting
    # @!attribute system_name
    #   @return [String] the name of the service using this module
    class Configuration
      attr_reader :analytics
      attr_accessor :system_name

      # Create a new configuration. Sub configuration's will be used by the
      # various reporting sections.
      # @see Analytics::Configuration
      def initialize
        @analytics = Analytics::Configuration.new
      end
    end
  end
end
