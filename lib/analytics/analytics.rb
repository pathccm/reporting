# frozen_string_literal: true

require_relative "channels/amplitude"
require_relative "channels/console"
require_relative "../types/trigger"
require_relative "../types/user_type"

module Path
  module Reporting
    class Analytics
      def initialize(config)
        @config = config
      end

      # Get clients for reporting events based on environment
      def clients
        if @clients.nil?
          @clients = {
            amplitude: setup_amplitude,
            console: setup_console
          }
        end

        @clients
      end

      def setup_amplitude
        # Amplitude reporting for metrics
        return Path::Reporting::Analytics::Channels::Amplitude.new @config if @config.amplitude_enabled?

        nil
      end

      def setup_console
        return Path::Reporting::Analytics::Channels::Console.new @config if @config.console_enabled?

        nil
      end

      def format_event_name(product_code:, product_area:, name:)
        formatted_code = product_code.gsub(" ", "_").upcase
        formatted_area = product_area.split(" ").each(&:capitalize!).join("")
        formatted_desc = name.capitalize.gsub(" ", "_")
        "#{formatted_code}_#{formatted_area}_#{formatted_desc}"
      end

      def record(
        product_code:,
        product_area:,
        name:,
        user:,
        user_type: UserType.PATIENT,
        trigger: Trigger.INTERACTION,
        metadata: {}
      )
        throw Error("No user provided when reporting analytics") unless user
        throw Error("Invalid UserType #{user_type}") unless UserType.valid?(user_type)
        throw Error("Invalid Trigger #{trigger}") unless Trigger.valid?(trigger)

        all_succeeded = true
        exceptions = {}
        clients.each do |_reporter, client|
          next if client.nil?

          begin
            event_name = format_event_name(product_code: product_code, product_area: product_area, name: name)
            client.record(
              name: event_name,
              user: user,
              user_type: user_type,
              metadata: metadata,
              trigger: trigger
            )
            exceptions[client.channel_name] = nil
          rescue StandardError => e
            all_succeeded = false
            exceptions[client.channel_name] = e
          end
        end

        {
          all_succeeded: all_succeeded,
          exceptions: exceptions
        }
      end

      def reset!
        @clients = nil
      end
    end
  end
end
