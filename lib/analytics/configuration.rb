# frozen_string_literal: true

module Path
  module Reporting
    class Analytics
      class Configuration
        attr_accessor :console_enabled
        attr_reader :amplitude_config, :console_logger

        def initialize
          @console_enabled = false
          @console_logger = nil
          @amplitude_enabled = false
          @amplitude_config = nil
        end

        def logger=(logger)
          @console_enabled = !logger.nil?
          @console_logger = logger
        end

        alias console= logger=

        def console_enabled?
          @console_enabled && @console_logger
        end

        def amplitude_config=(conf)
          @amplitude_enabled = !conf.nil?
          @amplitude_config = conf
        end

        alias amplitude= amplitude_config=

        def amplitude_enabled?
          @amplitude_enabled && @amplitude_config
        end
      end
    end
  end
end
