# frozen_string_literal: true

require "amplitude-api"

# See https://developers.amplitude.com/docs/http-api-v2#schemauploadrequestbody
API_METADATA_TO_ELEVATE = [
  "device_id",
  "app_version",
  "platform",
  "os_name",
  "os_version",
  "device_brand",
  "device_manufacturer",
  "device_model",
  "carrier",
  "country",
  "region",
  # We do not elevate city because at that level it is possibly PII
  "dma",
  "language",
  "price",
  "quantity",
  "revenue",
  "productId",
  "revenueType",
  # We do not elevate lat/long/IP because it is PII (IP at least for analytics)
  "event_id",
  "session_id",
  "insert_id",
  "plan"
].freeze

# Amplitue is not HIPAA compliant, so there are a number of PII things we want
# to make sure to filter out. These are keys (all lowercase) that are things
# we want to filter. Lowercased matching keys in data are obfuscated.
DISALLOWED_METADATA_PII_KEYS = %w[
  email
  name
  first_name
  firstname
  last_name
  lastname
  zip
  ssn
  dob
  address
  phone
  contactinfo
  patient_chart_id
].freeze

# Don't clean to infinity (and beyond)
MAX_METADATA_DEPTH = 4

module Path
  module Reporting
    class Analytics
      # Amplitude analytics is our primary analytics channel for production
      class Amplitude
        attr_reader :config

        # Setup and configure AmplitudeAPI with the given configuration
        # @param config [AmplitudeAPI::Config] the configuration for AmplitudeAPI
        # @see https://www.rubydoc.info/gems/amplitude-api/AmplitudeAPI/Config AmplitudeAPI::Config Documentation
        # @see https://github.com/toothrot/amplitude-api AmplitudeAPI repository
        def initialize(config)
          @config = config

          config.analytics.amplitude_config.each do |key, value|
            AmplitudeAPI.config.instance_variable_set("@#{key}", value)
          end
        end

        # Record the metadata to Amplitude
        # @param name [String] Formatted name to send to Amplitude
        # @param user [Hash] User object. Must contain `:id` and no PII
        # @param user_type [UserType] Type of `user`
        # @param trigger [Trigger] Trigger for this event
        # @param metadata [Hash] Metadata to send with the event
        # @see Analytics
        def record(name:, user:, user_type:, trigger:, metadata: {})
          user = user.dup
          metadata = metadata.dup
          user[:user_type] = user_type
          metadata[:trigger] = trigger
          metadata[:system_name] = config.system_name

          event_props = {
            user_id: (user[:id] || user['id']).to_s,
            user_properties: scrub_pii(user),
            event_type: name,
            event_properties: scrub_pii(metadata),
          }
          API_METADATA_TO_ELEVATE.each do |key|
            event_props[key] = metadata[key] if metadata.key? key
          end

          response = AmplitudeAPI.track AmplitudeAPI::Event.new event_props
          raise Error.new(response.body) unless response.success?
          response
        end

        # Scrub known PII keys from a hash
        # @private
        def scrub_pii(data, depth: 0)
          return "[DATA]" if depth > MAX_METADATA_DEPTH

          case data
          when Hash
            data = data.dup
            # Replace any disallowed keys, and recurse for allowed values
            data.each do |key, val|
              data[key] = if DISALLOWED_METADATA_PII_KEYS.include? key.to_s
                            "XXXXXXXX"
                          else
                            scrub_pii(val, depth: depth + 1)
                          end
            end
          when Array
            return data.map { |item| scrub_pii(item, depth: depth + 1) }
          end

          data
        end
      class Error < StandardError; end
      end
    end
  end
end
