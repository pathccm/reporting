# frozen_string_literal: true

require_relative "analytics/amplitude"
require_relative "analytics/console"
require_relative "types/trigger"
require_relative "types/user_type"

module Path
  module Reporting
    # Our primary class for reporting analytics data. Once configured, this
    # class can report analytics to any and all enabled and configured
    # reporters.
    #
    # This class is not a singleton, but is exposed via the {Reporting.analytics}
    # property once the Reporting module is initialized
    class Analytics
      # Create a new analytics reporter with the given configuration
      # @param config [Analytics::Configuration] configuration to use
      def initialize(config)
        @config = config
      end

      # Get clients for reporting events based on environment
      # @private
      def clients
        if @clients.nil?
          @clients = {
            amplitude: setup_amplitude,
            console: setup_console
          }
        end

        @clients
      end

      # @private
      def setup_amplitude
        # Amplitude reporting for metrics
        return Path::Reporting::Analytics::Amplitude.new @config if @config.analytics.amplitude_enabled?

        nil
      end

      # @private
      def setup_console
        return Path::Reporting::Analytics::Console.new @config if @config.analytics.console_enabled?

        nil
      end

      # Normalize the event name for easier searching in our analytics tools
      #
      # Generally the format is:
      # - Product code: All uppercase, _ separator between words
      # - Product area: Upper camel case, no spaces or separators
      # - (Event) Name: Sentence case, _ separator between words
      # @private
      def format_event_name(product_code:, product_area:, name:)
        formatted_code = product_code.gsub(" ", "_").upcase
        formatted_area = product_area.split(" ").each(&:capitalize!).join("")
        formatted_desc = name.capitalize.gsub(" ", "_")
        "#{formatted_code}_#{formatted_area}_#{formatted_desc}"
      end

      # Record analytics data to our enabled analytics channel
      #
      # This is the primary (and at the moment only) way to report analytics
      # data in our systems. Every configured analytics reporter will record
      # the event with the data given here.
      #
      # @note ***No patient PII or PHI is allowed in our analytics data.***
      #   By default we will attempt to strip this out of user data as well
      #   as metadata, but this is imperfect and should not be relied on.
      #   Instead, proactively exclude that data before it gets here.
      # @note The `product_code`, `product_area`, and `name` parameters will
      #   be formatted for easier searching automatically. Feel free to use
      #   regular text formatting here. E.g. "Self Scheduling" or "Hold booked"
      #
      # @param product_code [String] Code denoting which product this event
      #   occurred within. For example, "Self Scheduling". Can be used to view
      #   all the events that happen in a specific product
      #
      #   Bias names toward whatever the major user-facing component is. For
      #   example, Therapy or Operations.
      # @param product_area [String] Area of the product that event relates to.
      #   For example, “Appointment Booking” or “User Settings”. Can be used to
      #   see all events in a particular product area, as well as in rare cases
      #   be used across product codes to show events across the system.
      #
      #   Bias this name toward the particular flow or feature being used,
      #   e.g. Scheduling
      # @param name [String] Short plain text description of the event that is
      #   being recorded. For example, “Hold booked”
      #
      #   Follow the format: “Object action [descriptor]”. For example,
      #   “Hold converted to appointment” or “Appointment deleted”
      # @param user [Hash] A simple hash containing relevant user information.
      #   **This information should never contain any PII or PHI**. There does,
      #   however, need to be an `id` property to uniquely identify the user.
      #
      #   One of the following (in order):
      #
      #   1. Patient/User
      #   2. If it does not relate to a patient, Provider
      #   3. If it does not relate to a patient or provider, Insurer
      #   4. If it does not relate to a patient, provider, or insurer, use external system ID information
      #       - E.g. for Zocdoc, this maybe the primary key for their API key
      #       - Do not use an API key as an identifier, instead use another key like the id in our database for that key
      #
      #   If a different user (like an ops person) took an action, put an ID
      #   for them under `agent_id` in the metadata
      # @param user_type [Reporting::UserType] The type of user we are reporting
      #   this event for
      # @param trigger [Reporting::Trigger] What triggered this event to be
      #   recoreded (e.g. a page view, or an interaction).
      # @param metadata [Hash] Metadata to report alongside the analytics event.
      #    **This should not contain any PII or PHI*
      #
      # @example
      #   PathReporting.analytics.record(
      #     product_code: Constants::ANALYTICS_PRODUCT_CODE,
      #     product_area: Constants::ANALYTICS_PRODUCT_AREA_MATCHING,
      #     name: 'Preferred provider multiple valid matches',
      #     user: @contact.analytics_friendly_hash,
      #     user_type: PathReporting::UserType::PATIENT,
      #     trigger: PathReporting::Trigger.PAGE_VIEW,
      #     metadata: analytics_metadata,
      #   )
      # @example Validating Successful Reporting
      #    analytics_reported = PathReporting.analytics.record(
      #      product_code: Constants::ANALYTICS_PRODUCT_CODE,
      #      product_area: Constants::ANALYTICS_PRODUCT_AREA_MATCHING,
      #      name: 'No preferred provider',
      #      user: @contact.analytics_friendly_hash,
      #      user_type: PathReporting::UserType::PATIENT,
      #      trigger: PathReporting::Trigger.PAGE_VIEW,
      #    )
      #
      #    analytics_reported.each do |status|
      #      Rails.logger.warn("#{status.reporter} failed") unless status.result.nil?
      #    end
      #
      # @raise [StandardError] if no user is provided or user does not have id
      # @raise [StandardError] if user_type is not a Reporting::UserType
      # @raise [StandardError] if trigger is not a Reporting::Trigger
      #
      # @return [Array] An array of result hashes with two keys:
      #
      #     - `reporter` [String] the analytics reporter the result is for
      #     - `result` [nil | StandardError] what the result of running this
      #        reporter was. If it did not run, it will always be `nil`
      #
      # @see https://docs.google.com/document/d/1axnk1EkKCb__sxtvMomrPNup3wsviDOAefQWwXU3Z3U/edit# Analytics Guide
      # @see Reporting::UserType
      # @see Reporting::Trigger
      def record(
        product_code:,
        product_area:,
        name:,
        user:,
        user_type: UserType::PATIENT,
        trigger: Trigger::INTERACTION,
        metadata: {}
      )
        throw Error.new("No user hash provided when reporting analytics") if !user.is_a?(Hash) || !(user[:id] || user["id"])
        throw Error.new("Invalid UserType #{user_type}") unless UserType.valid?(user_type)
        throw Error.new("Invalid Trigger #{trigger}") unless Trigger.valid?(trigger)

        clients.map do |reporter, client|
          {
            reporter: reporter.to_s,
            result: send_event_to_client(client, {
                                           name: format_event_name(product_code: product_code, product_area: product_area, name: name),
                                           user: user,
                                           user_type: user_type,
                                           metadata: metadata,
                                           trigger: trigger
                                         })
          }
        end
      end

      # Wraps sending to the client in a rescue so we can report results
      # without causing other reporters to not run
      # @private
      def send_event_to_client(client, event)
        client&.record(**event)
      rescue StandardError => e
        e
      end

      # Primarily used for testing
      # @private
      def reset!
        @clients = nil
      end
    end
  end
end
