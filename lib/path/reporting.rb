# frozen_string_literal: true

require_relative "reporting/analytics"
require_relative "reporting/configuration"
require_relative "reporting/version"

# Path is just a wrapper module so we can group any path specific gems under
# this module heading
module Path
  # The `Reporting` module is our general, all-purpose reporting tool for
  # analytics, metrics, performance, and any other data. This module is
  # meant to be a one-stop shop for all of our ruby code to import and have
  # everything they need to track all the things
  module Reporting
    # @private
    class Error < StandardError; end

    class << self
      # Initialize our reporting setup. This is required to call before
      # the module is ready to use.
      #
      # To configure this module, pass in a block that accepts a {Configuration}
      # parameter. Using this parameter you can setup any reporting systems
      # that you need.
      #
      # Each sub-type of reporting will have its own configuration. For example,
      # to configure analytics reporting, you can use the `analytics` property
      # on the {Configuration} object passed in, which will be an instance of
      # {Analytics::Configuration}.
      #
      # @example Basic analytics setup
      #   Path::Reporting.init do |config|
      #     config.analytics.logger = Rails.logger
      #   end
      # @example If no configuration is needed, you still need to call this method
      #   Path::Reporting.init
      # @yieldparam config [Configuration] the Configuration object to set any and all configuration on
      # @return [self]
      # @see Configuration
      # @see Analytics::Configuration
      def init
        @initialized = true
        @config = Configuration.new
        yield(@config) if block_given?

        @analytics = Path::Reporting::Analytics.new @config.analytics
        self
      end

      # @raise [Error] if the Path:Reporting module has not been initialized
      # @return [Analytics] the configured analytics reporting module
      def analytics
        raise Error, "Must call init on Path::Reporting library before using" unless @initialized

        @analytics
      end

      # Resets the module to an uninitialized state. Mostly used for testing
      # @private
      def reset!
        @initialized = false
        @config = nil
        @analytics = nil
        self
      end
    end
  end
end
