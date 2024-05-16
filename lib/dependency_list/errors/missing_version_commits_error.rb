# frozen_string_literal: true

module DependencyList
  module Errors
    ## When there are version commits overrides in config, but for different versions
    class MissingVersionCommitsError < StandardError
      def initialize(spec, gem_version_commits)
        super(<<~TEXT.delete("\n"))
          There are version commits overrides `#{gem_version_commits}` for `#{spec.name}`,
          but not for version `#{spec.version}`
        TEXT
      end
    end
  end
end
