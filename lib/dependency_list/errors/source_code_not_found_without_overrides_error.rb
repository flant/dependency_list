# frozen_string_literal: true

module DependencyList
  module Errors
    ## When we can't find existing source code URI
    class SourceCodeNotFoundWithoutOverridesError < StandardError
      def initialize(base, variants)
        super(<<~TEXT.delete("\n"))
          Source code URI not found for `#{base}` with variants `#{variants}`,
          also there are no version commit overrides
        TEXT
      end
    end
  end
end
