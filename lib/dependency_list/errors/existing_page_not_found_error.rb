# frozen_string_literal: true

module DependencyList
  module Errors
    ## General error when some page not found, by design can be rescued
    class ExistingPageNotFoundError < StandardError
      def initialize(base, variants)
        super("Existing page not found for base `#{base}` with variants `#{variants}`")
      end
    end
  end
end
