# Dependency List

List project's dependencies in desired format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dependency_list'
```

And then execute:

```shell
bundle install
```

Or install it yourself as:

```shell
gem install dependency_list
```

## Usage

```shell
bundle exec dependency_list
```

### Options

*   `--fields`: you can specify only required fields, they will be printed separated by `Tab`
    (this is useful for pasting into Google Spreadsheets).
    Without this option all fields will be printed in human-readable format.

*   `--renew-cache`: remove cache, execute all requests again, saves the new cache.

### Config file

It is expected in working directory with `.dependency_list.yml` name.

Example:

```yaml
## You can exclude internal or other gems here from processing and output
exclude:
  - some_internal_gem
  - another_non_improtant_gem

## You can redefine some gems versions by commits, for example when there is a new release,
## but without tag. The commit hash will be used in URIs for the gem with this version.
## Format: `version_string: commit`
version_commits:
  aasm:
    ## https://github.com/aasm/aasm/commit/011118b639b264e044cdb9171d5bdece7bbaee28#commitcomment-141713787
    '5.5.0': 011118b

## You can redefine the whole source code URIs by any string,
## for example when a gem has outdated links in `gemspec`, not too accurate, or something else.
## Templating with `%{version}` (via Ruby's `format`) is supported (but not required).
source_code_uris:
  ## https://github.com/getsentry/sentry-ruby/pull/2311
  sentry-rails: 'https://github.com/getsentry/sentry-ruby/tree/%{version}/sentry-rails'
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to rubygems.org.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/flant/dependency_list).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
