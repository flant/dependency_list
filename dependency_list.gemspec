# frozen_string_literal: true

require_relative 'lib/dependency_list/version'

Gem::Specification.new do |spec|
  spec.name        = 'dependency_list'
  spec.version     = DependencyList::VERSION

  spec.summary     = "List project's dependencies in desired format"
  spec.description = <<~DESC
    List project's dependencies in desired format. Includes HTTP checks for URIs existance.
  DESC

  spec.authors     = ['Alexander Popov']
  spec.email       = ['aleksandr.popov@flant.com']
  spec.license     = 'MIT'

  github_uri = "https://github.com/flant/#{spec.name}"

  spec.homepage = github_uri

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'bug_tracker_uri' => "#{github_uri}/issues",
    'changelog_uri' => "#{github_uri}/blob/v#{spec.version}/CHANGELOG.md",
    'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
    'homepage_uri' => spec.homepage,
    'source_code_uri' => github_uri
  }

  spec.files = Dir['{lib,exe}/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']

  spec.bindir = 'exe'
  spec.executables << 'dependency_list'

  spec.required_ruby_version = '>= 3.1', '< 4'

  spec.add_runtime_dependency 'alt_memery', '~> 2.0'
  spec.add_runtime_dependency 'clamp', '~> 1.3'
  spec.add_runtime_dependency 'dry-inflector', '~> 1.0'
  spec.add_runtime_dependency 'faraday', '~> 2.9'
  spec.add_runtime_dependency 'faraday-follow_redirects', '~> 0.3.0'
end
