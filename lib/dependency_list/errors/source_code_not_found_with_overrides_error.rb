# frozen_string_literal: true

module DependencyList
  module Errors
    ## When we can't find existing source code URI
    class SourceCodeNotFoundWithOverridesError < StandardError
      def initialize(base, variants)
        super("Source code URI not found for `#{base}`, even with overriden version commit `#{variants}`")
      end
    end
  end
end
