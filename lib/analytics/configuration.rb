# frozen_string_literal: true

module Path
  module Reporting
    class Analytics
      # Configuration for analytics reporting. Generally this is for
      # configuring amplitude and/or a logger that analytics should
      # be reported to
      # @!attribute amplitude_config
      #   Set the configuration for the AmplitudeAPI gem
      #   @return [Hash] amplitude configuration options as passed along to the amplitude-api gem
      #   @see https://www.rubydoc.info/gems/amplitude-api/AmplitudeAPI/Config AmplitudeAPI::Config
      # @!attribute logger
      #   The logger for the console logging analytics reporter
      #   @return [#info] a logging interface with a .info method we can log analytics to
      #   @example
      #     conf.logger = Rails.logger
      class Configuration
        attr_reader :amplitude_config, :logger

        # New Configuration with all reporting off by default
        def initialize
          @console_enabled = false
          @logger = nil
          @amplitude_enabled = false
          @amplitude_config = nil
        end

        def logger=(logger)
          @console_enabled = !logger.nil?
          @logger = logger
        end

        alias console= logger=

        # Check if the logger has been configured and is available for use
        # @return [Boolean] if logger is available for use
        def console_enabled?
          @console_enabled && @logger
        end

        # Set the configuration for the AmplitudeAPI gem
        # @param conf [Hash] configuration options for amplitude
        # @return [Hash] amplitude configuration options as passed along to the amplitude-api gem
        # @see https://www.rubydoc.info/gems/amplitude-api/AmplitudeAPI/Config AmplitudeAPI::Config
        def amplitude_config=(conf)
          @amplitude_enabled = !conf.nil?
          @amplitude_config = conf
        end

        alias amplitude= amplitude_config=

        # Check if Amplitude has been configured and is available for use
        # @return [Boolean] if Amplitude is available for use
        def amplitude_enabled?
          @amplitude_enabled && @amplitude_config
        end
      end
    end
  end
end
