# frozen_string_literal: true

require 'faraday'
require 'faraday/follow_redirects'
require 'memery'

require_relative 'errors/existing_page_not_found_error'
require_relative 'errors/missing_version_commits_error'
require_relative 'errors/source_code_not_found_with_overrides_error'
require_relative 'errors/source_code_not_found_without_overrides_error'

module DependencyList
  ## Process one dependency from its spec, find and check all possible links
  class DependencyProcessor
    include Memery

    CONNECTION = Faraday.new do |connection|
      ## There are `http` (not `https`) links to GitHub, we can just follow redirects
      connection.response :follow_redirects
    end

    LICENSE_FILENAME_VARIANTS = %w[
      LICENSE LICENCE LICENSE.txt License.txt LICENSE.md MIT-LICENSE MIT-LICENSE.md
    ].freeze

    def initialize(dependency, config:, cache:)
      @dependency = dependency

      @spec = @dependency.to_spec

      @version_string = @dependency.git ? @dependency.source.revision : @spec.version.to_s

      @config = config

      @cache = cache
    end

    def process
      {
        name: @spec.name,
        version: @version_string,
        source_code_uri:,
        source_code_uri_with_version:,
        license: @spec.license,
        license_uri:
      }
    end

    memoize def cached_data
      cached_version = @cache.dig(@spec.name, :version)
      @cache.delete @spec.name if cached_version && cached_version != @version_string
      @cache.fetch(@spec.name, {})
    end

    private

    memoize def source_code_uri
      result = cached_data.fetch(:source_code_uri) do
        spec_value = @spec.metadata['source_code_uri'] || @spec.homepage

        if (git_uri = @dependency.git&.chomp('.git')) && !spec_value.include?(git_uri)
          case spec_value
          when %r{://github\.com/}
            spec_value.sub! %r{^https?://github\.com/[^/]+/[^/]+}, git_uri
          else
            raise "Dependency `#{@dependency.name}` has git source, but unknown URI in specs: `#{spec_value}`"
          end
        end

        break spec_value unless (overriden_value = @config.dig('source_code_uris', @spec.name))

        if overriden_value == spec_value
          raise "Overriden source code URI for `#{@spec.name}` matches actual from gemspec"
        end

        ## Templates with `%{version}` are allowed there
        format overriden_value, version: @version_string
      end

      raise "No source code URI for `#{@spec.name}`" unless result

      result
    end

    memoize def source_code_uri_with_version
      cached_data.fetch(:source_code_uri_with_version) do
        break source_code_uri if source_code_uri.include?(@version_string)

        case source_code_uri
        when /github\.com/
          source_code_uri_with_version_check File.join(source_code_uri, '/tree/')
        else
          raise "Unsupported source code URI `#{source_code_uri}` for `#{@spec.name}`"
        end
      end
    end

    memoize def license_uri
      cached_data.fetch(:license_uri) do
        base =
          case source_code_uri_with_version
          when /github\.com/
            source_code_uri_with_version.sub('/tree/', '/blob/')
          else
            raise "Unsupported source code URI with version `#{source_code_uri_with_version}` for `#{@spec.name}`"
          end

        existing_page_check base, LICENSE_FILENAME_VARIANTS
      end
    end

    def source_code_uri_with_version_check(base, variants = ["v#{@version_string}", @version_string])
      gem_version_commits = @config.dig('version_commits', @spec.name)
      version_commit = gem_version_commits[@version_string] if gem_version_commits

      result =
        begin
          existing_page_check base, variants
        rescue Errors::ExistingPageNotFoundError
          raise Errors::SourceCodeNotFoundWithoutOverridesError.new(base, variants) unless gem_version_commits

          raise Errors::MissingVersionCommitsError.new(@spec, gem_version_commits) unless version_commit

          raise Errors::SourceCodeNotFoundWithOverridesError.new(base, variants) if variants == [version_commit]

          variants = [version_commit]

          retry
        end

      if version_commit && result && !variants.include?(version_commit)
        raise "Version commit is overriden for `#{@spec.name}`, but standard URI exists: #{result}"
      end

      result
    end

    def existing_page_check(base, variants)
      # puts 'existing_page_check call'
      existing_page = variants.find do |variant|
        ## `File.join` for joining via single `/`, even if it's already there
        uri = File.join(base, variant)
        ## `break` will return its value instead of found element
        break uri if CONNECTION.head(uri).success?
      end

      raise Errors::ExistingPageNotFoundError.new(base, variants) unless existing_page

      existing_page
    end
  end
end
