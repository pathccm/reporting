# frozen_string_literal: true

module Path
  module Reporting
    class Analytics
      # Simple non-structure console logging for analytics data. Most helpful
      # for development or backup rather than analysis.
      class Console
        # Create new console logging analytics reporter
        # @param config [Analytics::Configuration] the configuration for the reporter
        # @see Analytics::Configuration
        def initialize(config)
          @config = config.analytics
        end

        # Log the analytics event to the configured logger
        # @param name [String] Formatted name to send to Amplitude
        # @param user [Hash] User object. Must contain `:id` and no PII
        # @param user_type [UserType] Type of `user`
        # @param trigger [Trigger] Trigger for this event
        # @param metadata [Hash] Metadata to send with the event
        # @see Analytics
        def record(name:, user:, user_type:, trigger:, metadata: {})
          @config.logger.info("[#{trigger}]:#{name} - #{user.inspect} (#{user_type}) #{metadata.nil? ? "" : metadata.inspect}")
        end
      end
    end
  end
end
