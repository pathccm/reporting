# frozen_string_literal: true

module Path
  module Reporting
    class Trigger
      class << self
        INTERACTION = "Interaction"
        PAGE_VIEW = "Page view"
        AUTOMATION = "Automation"

        def triggers
          [
            INTERACTION,
            PAGE_VIEW,
            AUTOMATION
          ]
        end

        def valid?(maybe_trigger)
          triggers.includes? maybe_trigger
        end
      end
    end
  end
end
