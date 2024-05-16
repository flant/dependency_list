# frozen_string_literal: true

require 'clamp'
require 'dry/inflector'
require 'yaml'

require_relative 'dependency_processor'

module DependencyList
  ## CLI logic which used in `exe/`
  class Command < Clamp::Command
    INFLECTOR = Dry::Inflector.new do |inflections|
      inflections.acronym 'URI'
    end

    ## https://github.com/mdub/clamp/pull/118#issuecomment-1184359621
    FIELDS = %i[
      name version source_code_uri source_code_uri_with_version license license_uri
    ].freeze

    option(
      '--fields',
      'FIELDS',
      "dependency fields for output, comma-separated list, available values: #{FIELDS.join(', ')}"
    ) do |arg|
      arg_array = arg.split(',').map(&:to_sym)

      raise ArgumentError, 'invalid field value' if (arg_array - FIELDS).any?

      arg_array
    end

    option '--renew-cache', :flag, 'clear the current cache and build a new one'

    def execute
      @config = YAML.load_file File.join(Dir.pwd, '/.dependency_list.yml')

      load_cache

      list_dependencies
    end

    private

    def load_cache
      @cache_file = File.join(Dir.pwd, '/tmp/licenses.yml')

      @cache =
        if renew_cache?
          FileUtils.rm_f @cache_file
          {}
        else
          File.exist?(@cache_file) ? YAML.load_file(@cache_file) : {}
        end
    end

    def list_dependencies
      Bundler.load.current_dependencies.map.each do |dependency|
        ## Right now it describes all dependencies, even for development and linting,
        ## but you can exclude specific ones in the config file.
        ## Exclusion by `Gemfile` groups can be added later.
        # next if (dependency.groups & %i[development]).any?

        next if @config['exclude']&.include? dependency.name

        dependency_processor = DependencyProcessor.new(dependency, config: @config, cache: @cache)

        ## TODO: Execute only asked fields
        dependency_data = dependency_processor.process

        cache_dependency dependency_data if dependency_processor.cached_data.empty?

        print_dependency dependency_data
      end
    end

    def cache_dependency(dependency_data)
      @cache[dependency_data[:name]] = dependency_data

      ## Rewrite file for each dependency to save cache in case of fails
      File.write @cache_file, @cache.to_yaml
    end

    def print_dependency(dependency_data)
      if fields
        ## Tab auto-separate columns while pasting into Google Spreadsheets.
        ## It can be an option later.
        puts dependency_data.values_at(*fields).join("\t")
      else
        puts <<~OUTPUT
          * #{FIELDS.map { |field| "#{INFLECTOR.humanize(field)}: #{dependency_data[field]}" }.join("\n  ")}

        OUTPUT
      end
    end
  end
end
