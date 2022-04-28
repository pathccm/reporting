# frozen_string_literal: true

module Path
  module Reporting
    class UserType
      class << self
        PATIENT = "Patient"
        PROVIDER = "Provider"
        INSURER = "Insurer"
        OPERATOR = "Operator"
        DEVELOPER = "Developer"
        SYSTEM = "System"

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

        def valid?(maybe_type)
          types.includes? maybe_type
        end
      end
    end
  end
end
