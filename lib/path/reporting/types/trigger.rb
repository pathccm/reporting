# frozen_string_literal: true

module Path
  module Reporting
    # The trigger or cause of reporting events
    class Trigger
      class << self
        # Interaction: When a direct intentional user action is the cause of
        # this event that is not a simple navigation. E.g. Submitted form or
        # changed password
        INTERACTION = "Interaction"
        # Page view: When the event was an indirect result of viewing something.
        # E.g. auto-assigning a provider or appointment because the user has an
        # existing provider already
        # @note Because of usage limits, we do not want to record page views
        #   as a separate action, this is only for indirect consequences that
        #   result in a change in something either for the user or for our
        #   systems
        PAGE_VIEW = "Page view"
        # Automation: Some automation or tool was the cause of this event
        AUTOMATION = "Automation"

        # @private
        def triggers
          [
            INTERACTION,
            PAGE_VIEW,
            AUTOMATION
          ]
        end

        # Check if a given item is a valid Trigger
        # @param maybe_trigger [Any] item to check
        def valid?(maybe_trigger)
          triggers.includes? maybe_trigger
        end
      end
    end
  end
end
