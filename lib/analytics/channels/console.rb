# frozen_string_literal: true

module Path
  module Reporting
    class Analytics
      module Channels
        class Console
          attr_reader :channel_name

          def initialize(config)
            @channel_name = "Console"
            @config = config
          end

          def record(name:, user:, user_type:, trigger:, metadata: {})
            @config.console_logger.info("[#{trigger}]:#{name} - #{user.inspect} (#{user_type}) #{metadata.nil? ? "" : metadata.inspect}")
          end
        end
      end
    end
  end
end
