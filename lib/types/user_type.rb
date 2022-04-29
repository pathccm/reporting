# frozen_string_literal: true

module Path
  module Reporting
    # User types that data may be recorded for or on
    class UserType
      class << self
        # Patient or potential patient
        PATIENT = "Patient"
        # Provider, which can be any sub-type (e.g. therapist)
        PROVIDER = "Provider"
        # Insurer, not currently in-use
        INSURER = "Insurer"
        # Operator or any internal non-developer
        OPERATOR = "Operator"
        # Developer; mostly relevant for backfills or manual intervention
        DEVELOPER = "Developer"
        # System, either first-party or third-party
        SYSTEM = "System"

        # @private
        def types
          [
            PATIENT,
            PROVIDER,
            INSURER,
            OPERATOR,
            DEVELOPER,
            SYSTEM
          ]
        end

        # Check if a given item is a valid UserType
        # @param maybe_type [Any] item to check
        def valid?(maybe_type)
          types.includes? maybe_type
        end
      end
    end
  end
end
