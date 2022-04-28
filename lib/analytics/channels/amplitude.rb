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
      module Channels
        # Amplitude analytics is our primary analytics channel for production
        class Amplitude
          attr_reader :channel_name

          def initialize(config)
            @channel_name = "Amplitude"
            @config = config

            config.amplitude_config.each do |key, value|
              AmplitudeAPI.config.instance_variable_set("@#{key}", value)
            end
          end

          def record(name:, user:, user_type:, trigger:, metadata: {})
            user = user.dup
            metadata = metadata.dup
            user[:user_type] = user_type
            metadata[:trigger] = trigger

            event_props = {
              user_id: user[:id].to_s,
              user_properties: scrub_pii(user),
              event_type: name,
              event_properties: scrub_pii(metadata)
            }
            API_METADATA_TO_ELEVATE.each do |key|
              event_props[key] = metadata[key] if metadata.key? key
            end

            AmplitudeAPI.track AmplitudeAPI::Event.new event_props
          end

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
        end
      end
    end
  end
end
